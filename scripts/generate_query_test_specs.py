#!/usr/bin/env python3
"""Generate tests/query_test_specs.json from query task headers.

The generator scans query files for header metadata:
- -- Task ID:
- -- Title:
- -- Deliverables:

It creates a test spec per query with baseline assertions plus
deliverable keyword checks that can be refined manually.
"""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


STOPWORDS = {
    "a",
    "an",
    "and",
    "are",
    "as",
    "at",
    "be",
    "by",
    "for",
    "from",
    "in",
    "into",
    "is",
    "it",
    "of",
    "on",
    "or",
    "that",
    "the",
    "to",
    "using",
    "with",
}


@dataclass
class QueryMetadata:
    task_id: str
    title: str
    deliverables: list[str]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate per-query test spec file")
    parser.add_argument(
        "--queries-dir",
        default="queries",
        help="Directory containing .pgsql query files",
    )
    parser.add_argument(
        "--out",
        default="tests/query_test_specs.json",
        help="Path to output JSON spec",
    )
    return parser.parse_args()


def extract_metadata(sql_text: str) -> QueryMetadata:
    task_id = "UNKNOWN"
    title = "Untitled"
    deliverables_raw = ""

    for line in sql_text.splitlines():
        if line.startswith("-- Task ID:"):
            task_id = line.split(":", 1)[1].strip()
        elif line.startswith("-- Title:"):
            title = line.split(":", 1)[1].strip()
        elif line.startswith("-- Deliverables:"):
            deliverables_raw = line.split(":", 1)[1].strip()

    deliverables = []
    if deliverables_raw:
        parts = [p.strip() for p in re.split(r"[;,]", deliverables_raw)]
        deliverables = [p for p in parts if p]

    return QueryMetadata(task_id=task_id, title=title, deliverables=deliverables)


def keyword_candidates(deliverable: str, max_keywords: int = 4) -> list[str]:
    tokens = re.findall(r"[a-zA-Z_][a-zA-Z0-9_]*", deliverable.lower())
    filtered: list[str] = []
    for token in tokens:
        if token in STOPWORDS or len(token) < 3:
            continue
        filtered.append(token)
    seen: set[str] = set()
    deduped: list[str] = []
    for token in filtered:
        if token in seen:
            continue
        seen.add(token)
        deduped.append(token)
    return deduped[:max_keywords]


def build_test_spec(query_path: Path, root: Path, existing: dict | None = None) -> dict:
    sql_text = query_path.read_text(encoding="utf-8")
    meta = extract_metadata(sql_text)
    rel_path = query_path.relative_to(root).as_posix()

    deliverable_checks = []
    for idx, item in enumerate(meta.deliverables, start=1):
        kws = keyword_candidates(item)
        deliverable_checks.append(
            {
                "name": f"deliverable_{idx}",
                "description": item,
                "any_of": kws,
            }
        )

    spec = {
        "id": meta.task_id,
        "title": meta.title,
        "query_file": rel_path,
        "enabled": True,
        "deliverables": meta.deliverables,
        "assertions": {
            "must_execute": True,
            "min_successful_statements": 1,
            "must_return_rows": False,
            "deliverable_keywords": deliverable_checks,
        },
        "custom_assertions": [
            {
                "name": "override_me",
                "sql": "SELECT TRUE AS pass",
                "enabled": False,
            }
        ],
    }

    if existing and isinstance(existing, dict):
        spec["enabled"] = existing.get("enabled", spec["enabled"])
        if isinstance(existing.get("custom_assertions"), list):
            spec["custom_assertions"] = existing["custom_assertions"]

    return spec


def main() -> int:
    args = parse_args()
    root = Path.cwd()
    queries_dir = (root / args.queries_dir).resolve()
    out_path = (root / args.out).resolve()

    if not queries_dir.exists():
        raise SystemExit(f"Queries directory not found: {queries_dir}")

    query_files = sorted(queries_dir.glob("*.pgsql"))
    existing_by_file: dict[str, dict] = {}
    if out_path.exists():
        try:
            existing_payload = json.loads(out_path.read_text(encoding="utf-8"))
            for test in existing_payload.get("tests", []):
                query_file = test.get("query_file")
                if isinstance(query_file, str):
                    existing_by_file[query_file] = test
        except json.JSONDecodeError:
            existing_by_file = {}

    tests = []
    for path in query_files:
        rel_path = path.relative_to(root).as_posix()
        tests.append(build_test_spec(path, root, existing=existing_by_file.get(rel_path)))

    payload = {
        "version": 1,
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "queries_dir": Path(args.queries_dir).as_posix(),
        "tests": tests,
    }

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    print(f"Generated {len(tests)} query test specs -> {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
