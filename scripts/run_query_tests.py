#!/usr/bin/env python3
"""Run query tests from tests/query_test_specs.json and produce pass/fail reports.

Usage:
  python scripts/run_query_tests.py --dsn "$env:DATABASE_URL"

Expected dependency:
  pip install psycopg[binary]
"""

from __future__ import annotations

import argparse
import json
import os
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    import psycopg
except Exception as exc:  # pragma: no cover - informative runtime failure
    raise SystemExit(
        "Missing dependency 'psycopg'. Install with: pip install psycopg[binary]"
    ) from exc


ROW_RETURNING_PREFIXES = ("select", "with", "explain", "show")


@dataclass
class StatementResult:
    index: int
    success: bool
    row_count: int | None
    error: str | None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run per-query SQL tests")
    parser.add_argument("--spec", default="tests/query_test_specs.json")
    parser.add_argument("--dsn", default=os.getenv("DATABASE_URL", ""))
    parser.add_argument("--json-out", default="artifacts/query_test_report.json")
    parser.add_argument("--md-out", default="artifacts/query_test_report.md")
    parser.add_argument(
        "--continue-on-error",
        action="store_true",
        help="Continue running statements after a failure",
    )
    return parser.parse_args()


def split_sql_statements(sql: str) -> list[str]:
    """Split SQL into statements while respecting quoted strings and comments."""
    # Some editors/tools may save UTF-8 with BOM; strip it to avoid parser errors.
    if sql.startswith("\ufeff"):
        sql = sql.lstrip("\ufeff")

    parts: list[str] = []
    buff: list[str] = []
    in_single = False
    in_double = False
    in_line_comment = False
    in_block_comment = False
    i = 0

    while i < len(sql):
        ch = sql[i]
        nxt = sql[i + 1] if i + 1 < len(sql) else ""

        if in_line_comment:
            buff.append(ch)
            if ch == "\n":
                in_line_comment = False
            i += 1
            continue

        if in_block_comment:
            buff.append(ch)
            if ch == "*" and nxt == "/":
                buff.append(nxt)
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue

        if not in_single and not in_double and ch == "-" and nxt == "-":
            in_line_comment = True
            buff.append(ch)
            buff.append(nxt)
            i += 2
            continue

        if not in_single and not in_double and ch == "/" and nxt == "*":
            in_block_comment = True
            buff.append(ch)
            buff.append(nxt)
            i += 2
            continue

        if ch == "'" and not in_double:
            in_single = not in_single
            buff.append(ch)
            i += 1
            continue

        if ch == '"' and not in_single:
            in_double = not in_double
            buff.append(ch)
            i += 1
            continue

        if ch == ";" and not in_single and not in_double:
            statement = "".join(buff).strip()
            if statement:
                statement = statement.lstrip("\ufeff")
                parts.append(statement)
            buff = []
            i += 1
            continue

        buff.append(ch)
        i += 1

    tail = "".join(buff).strip()
    if tail:
        tail = tail.lstrip("\ufeff")
        parts.append(tail)

    return parts


def is_row_returning(statement: str) -> bool:
    prefix = statement.strip().lower()
    return prefix.startswith(ROW_RETURNING_PREFIXES)


def execute_statements(
    conn: psycopg.Connection[Any],
    statements: list[str],
    continue_on_error: bool,
) -> list[StatementResult]:
    results: list[StatementResult] = []

    with conn.cursor() as cur:
        for idx, statement in enumerate(statements, start=1):
            try:
                cur.execute(statement)
                row_count: int | None = None
                if is_row_returning(statement):
                    rows = cur.fetchmany(1000)
                    row_count = len(rows)
                results.append(
                    StatementResult(
                        index=idx,
                        success=True,
                        row_count=row_count,
                        error=None,
                    )
                )
            except Exception as exc:  # pragma: no cover - runtime DB behavior
                results.append(
                    StatementResult(
                        index=idx,
                        success=False,
                        row_count=None,
                        error=str(exc),
                    )
                )
                if not continue_on_error:
                    break

    return results


def keyword_check(sql_text: str, check: dict[str, Any]) -> tuple[bool, str]:
    words = [w.lower() for w in check.get("any_of", []) if isinstance(w, str)]
    if not words:
        return True, "No keywords configured"
    sql_lower = sql_text.lower()
    found = [w for w in words if w in sql_lower]
    ok = len(found) > 0
    details = f"found={found}" if found else f"missing any_of={words}"
    return ok, details


def run_custom_assertions(
    conn: psycopg.Connection[Any], custom_checks: list[dict[str, Any]]
) -> list[dict[str, Any]]:
    results = []
    for check in custom_checks:
        if not check.get("enabled", False):
            results.append(
                {
                    "name": check.get("name", "unnamed"),
                    "pass": True,
                    "details": "Skipped (enabled=false)",
                }
            )
            continue

        sql = check.get("sql", "").strip()
        if not sql:
            results.append(
                {
                    "name": check.get("name", "unnamed"),
                    "pass": False,
                    "details": "Missing SQL",
                }
            )
            continue

        with conn.cursor() as cur:
            try:
                cur.execute(sql)
                row = cur.fetchone()
                value = bool(row[0]) if row else False
                results.append(
                    {
                        "name": check.get("name", "unnamed"),
                        "pass": value,
                        "details": f"first_col={value}",
                    }
                )
            except Exception as exc:  # pragma: no cover - runtime DB behavior
                results.append(
                    {
                        "name": check.get("name", "unnamed"),
                        "pass": False,
                        "details": str(exc),
                    }
                )
    return results


def evaluate_test(
    conn: psycopg.Connection[Any],
    root: Path,
    test: dict[str, Any],
    continue_on_error: bool,
) -> dict[str, Any]:
    query_file = root / test["query_file"]
    sql_text = query_file.read_text(encoding="utf-8")
    sql_text = sql_text.lstrip("\ufeff")
    statements = split_sql_statements(sql_text)

    # Run each test in an isolated transaction and roll it back.
    conn.rollback()
    conn.autocommit = False
    stmt_results = execute_statements(conn, statements, continue_on_error)
    conn.rollback()

    assertions = test.get("assertions", {})
    checks = []

    must_execute = bool(assertions.get("must_execute", True))
    if must_execute:
        ok = all(r.success for r in stmt_results)
        checks.append(
            {
                "name": "must_execute",
                "pass": ok,
                "details": f"successful={sum(1 for r in stmt_results if r.success)}/{len(stmt_results)}",
            }
        )

    min_ok = int(assertions.get("min_successful_statements", 1))
    successful = sum(1 for r in stmt_results if r.success)
    checks.append(
        {
            "name": "min_successful_statements",
            "pass": successful >= min_ok,
            "details": f"successful={successful}, required={min_ok}",
        }
    )

    if bool(assertions.get("must_return_rows", False)):
        row_returning = [r for r in stmt_results if r.row_count is not None]
        has_rows = any((r.row_count or 0) > 0 for r in row_returning)
        checks.append(
            {
                "name": "must_return_rows",
                "pass": has_rows,
                "details": "at least one row-returning statement produced rows",
            }
        )

    for check in assertions.get("deliverable_keywords", []):
        ok, details = keyword_check(sql_text, check)
        checks.append(
            {
                "name": f"deliverable_keyword:{check.get('name', 'unknown')}",
                "pass": ok,
                "details": details,
            }
        )

    # Run custom assertions in a dedicated transaction, always rollback.
    conn.rollback()
    conn.autocommit = False
    custom_results = run_custom_assertions(conn, test.get("custom_assertions", []))
    conn.rollback()
    checks.extend(custom_results)

    failed_statements = [r for r in stmt_results if not r.success]
    overall_pass = all(c["pass"] for c in checks)

    return {
        "id": test.get("id", "UNKNOWN"),
        "title": test.get("title", "Untitled"),
        "query_file": test.get("query_file"),
        "overall_pass": overall_pass,
        "statement_results": [r.__dict__ for r in stmt_results],
        "failed_statements": [r.__dict__ for r in failed_statements],
        "checks": checks,
    }


def write_markdown_report(path: Path, report: dict[str, Any]) -> None:
    lines = []
    lines.append("# Query Test Report")
    lines.append("")
    lines.append(f"Generated: {report['generated_at']}")
    lines.append(f"Total: {report['summary']['total']}  ")
    lines.append(f"Passed: {report['summary']['passed']}  ")
    lines.append(f"Failed: {report['summary']['failed']}")
    lines.append("")
    lines.append("| Task | Query File | Result |")
    lines.append("|---|---|---|")
    for t in report["tests"]:
        status = "PASS" if t["overall_pass"] else "FAIL"
        lines.append(f"| {t['id']} | {t['query_file']} | {status} |")
    lines.append("")

    for t in report["tests"]:
        status = "PASS" if t["overall_pass"] else "FAIL"
        lines.append(f"## {t['id']} - {t['title']} ({status})")
        lines.append("")
        lines.append(f"File: `{t['query_file']}`")
        lines.append("")
        lines.append("### Checks")
        lines.append("")
        lines.append("| Check | Result | Details |")
        lines.append("|---|---|---|")
        for c in t["checks"]:
            c_status = "PASS" if c["pass"] else "FAIL"
            details = str(c.get("details", "")).replace("|", "\\|")
            lines.append(f"| {c['name']} | {c_status} | {details} |")
        lines.append("")

        if t["failed_statements"]:
            lines.append("### Failed Statements")
            lines.append("")
            for fs in t["failed_statements"]:
                lines.append(f"- statement #{fs['index']}: {fs['error']}")
            lines.append("")

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    if not args.dsn:
        raise SystemExit("Provide a DSN via --dsn or DATABASE_URL")

    root = Path.cwd()
    spec_path = root / args.spec
    spec = json.loads(spec_path.read_text(encoding="utf-8"))

    enabled_tests = [t for t in spec.get("tests", []) if t.get("enabled", True)]
    results = []

    try:
        with psycopg.connect(args.dsn) as conn:
            for test in enabled_tests:
                results.append(evaluate_test(conn, root, test, args.continue_on_error))
    except psycopg.OperationalError as exc:
        err = str(exc)
        if "getaddrinfo failed" in err or "failed to resolve host" in err:
            guidance = (
                "Connection failed due to DNS resolution.\n"
                "Your environment may not resolve the direct Supabase DB host (IPv6-only).\n"
                "Try a pooler DSN (IPv4):\n"
                "postgresql://postgres.<project-ref>:<db-password>@aws-0-<region>.pooler.supabase.com:6543/postgres?sslmode=require"
            )
            raise SystemExit(f"{err}\n\n{guidance}") from exc
        if "Tenant or user not found" in err:
            guidance = (
                "Supabase pooler authentication failed.\n"
                "Common cause: wrong username format for the chosen host.\n\n"
                "Use direct host (port 5432):\n"
                "postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require\n\n"
                "Use pooler host (port 6543):\n"
                "postgresql://postgres.<project-ref>:<db-password>@aws-0-<region>.pooler.supabase.com:6543/postgres?sslmode=require\n\n"
                "Also verify you are using the database password (not anon/service keys) and URL-encode special characters in the password."
            )
            raise SystemExit(f"{err}\n\n{guidance}") from exc
        raise

    passed = sum(1 for r in results if r["overall_pass"])
    failed = len(results) - passed

    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "summary": {
            "total": len(results),
            "passed": passed,
            "failed": failed,
        },
        "tests": results,
    }

    json_out = root / args.json_out
    md_out = root / args.md_out
    json_out.parent.mkdir(parents=True, exist_ok=True)
    json_out.write_text(json.dumps(report, indent=2), encoding="utf-8")
    write_markdown_report(md_out, report)

    print(f"Report written: {json_out}")
    print(f"Report written: {md_out}")
    print(f"Summary: total={len(results)} passed={passed} failed={failed}")

    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
