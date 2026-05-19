# SQL Query Test Automation

## Overview

This repository includes a test automation framework for the SQL workbook.
The framework standardizes query validation by generating test definitions, executing query files in batch mode, evaluating assertions, and producing structured reports.

## Purpose

The framework is designed to provide repeatable quality checks for SQL exercises that would otherwise require manual validation.
It enables consistent pass/fail signaling at the task level and supports public project presentation with verifiable test artifacts.

## Architecture

The automation flow is composed of three stages:

1. Specification generation from query metadata.
2. Test execution and assertion evaluation.
3. Report generation for human and machine consumers.

## Components

### `scripts/generate_query_test_specs.py`
Role:
- Scans `queries/*.pgsql` files.
- Parses task headers (`Task ID`, `Title`, `Deliverables`).
- Generates or refreshes `tests/query_test_specs.json`.

Notes:
- Existing manual `custom_assertions` are preserved during regeneration.

### `scripts/run_query_tests.py`
Role:
- Connects to Postgres/Supabase.
- Executes each SQL file statement-by-statement.
- Evaluates configured checks and computes pass/fail outcomes.
- Writes both Markdown and JSON reports.

Operational safeguards:
- Handles UTF-8 BOM parsing issues.
- Emits targeted guidance for common Supabase connection failures.

### `scripts/run_query_tests.ps1`
Role:
- Provides a one-command PowerShell entry point for spec generation and test execution.

### `tests/query_test_specs.json` (generated)
Role:
- Stores per-query test configuration.

Configurable fields:
- `enabled`
- `assertions.must_return_rows`
- `assertions.deliverable_keywords`
- `custom_assertions`

### `artifacts/query_test_report.md` (generated)
Role:
- Human-readable execution report with summary and per-task details.

### `artifacts/query_test_report.json` (generated)
Role:
- Machine-readable execution report for CI/tooling integration.

## Assertion Model

Each query test may include:

- `must_execute`: all required statements execute successfully.
- `min_successful_statements`: minimum successful statement count.
- `must_return_rows`: optional row-return condition.
- `deliverable_keywords`: baseline deliverable alignment check.
- `custom_assertions`: strict SQL checks returning TRUE/FALSE.

Implementation guidance:
- Prefer `custom_assertions` for high-confidence validation of critical tasks.

## Security and Public Exposure

This repository is intended for public visibility. The following controls apply:

- Never commit real credentials.
- Use placeholder DSNs in documentation.
- Store runtime secrets in environment variables or secure secret stores.
- Use CI secret management for pipeline execution.

## Requirements

1. Python 3.9+
2. Postgres driver:

```bash
pip install psycopg[binary]
```

3. Valid database connection string via `DATABASE_URL` or `--dsn`.

## Supabase DSN Examples (Placeholders Only)

Direct endpoint:

```text
postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require
```

Pooler endpoint:

```text
postgresql://postgres.<project-ref>:<db-password>@aws-0-<region>.pooler.supabase.com:6543/postgres?sslmode=require
```

Connection notes:
- `sslmode=require` should always be set.
- Username format depends on host type:
  - direct host `db.<project-ref>.supabase.co` uses `postgres`
  - pooler host `aws-0-<region>.pooler.supabase.com` uses `postgres.<project-ref>`
- URL-encode special characters in passwords (`@`, `:`, `/`, `?`, `#`, `%`).

## Operating Procedure

### 1) Generate test specs

```bash
python scripts/generate_query_test_specs.py
```

### 2) (Optional) Add strict custom assertions

Example:

```json
{
  "name": "a1_love_search_returns_rows",
  "sql": "SELECT EXISTS (SELECT 1 FROM public.track WHERE name ILIKE '%love%')",
  "enabled": true
}
```

### 3) Run tests

PowerShell:

```powershell
$env:DATABASE_URL = "postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require"
python scripts/run_query_tests.py
```

PowerShell wrapper:

```powershell
$env:DATABASE_URL = "postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require"
./scripts/run_query_tests.ps1
```

DSN override:

```bash
python scripts/run_query_tests.py --dsn "postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require"
```

Pooler fallback (if direct host is unreachable):

```bash
python scripts/run_query_tests.py --dsn "postgresql://postgres.<project-ref>:<db-password>@aws-0-<region>.pooler.supabase.com:6543/postgres?sslmode=require"
```

## Output Artifacts

- `artifacts/query_test_report.md`
- `artifacts/query_test_report.json`

## CI Integration

Example pipeline steps:

```bash
python scripts/generate_query_test_specs.py
python scripts/run_query_tests.py --dsn "$DATABASE_URL"
```

Execution behavior:
- The test runner exits with non-zero status when one or more tests fail, allowing CI to enforce quality gates.
