# Query Test Automation

This folder contains generated test specs and test reports for query validation.

## What this solves

- Generates a test definition per query file automatically.
- Executes each query file statement-by-statement against Postgres/Supabase.
- Evaluates pass/fail assertions aligned to each file's task header.
- Produces machine-readable JSON and human-readable Markdown reports.

## Files

- `tests/query_test_specs.json` (generated): per-query test configuration.
- `artifacts/query_test_report.json` (generated): detailed run results.
- `artifacts/query_test_report.md` (generated): pass/fail summary report.

## Prerequisites

1. Python 3.9+
2. Postgres driver:

```bash
pip install psycopg[binary]
```

3. A valid DB connection string in `DATABASE_URL` (or pass `--dsn`).

## Supabase connection examples

Use placeholders only in docs. Never commit real credentials.

Recommended (direct database endpoint, best for script tooling):

```text
postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require
```

Alternative (Supabase pooler endpoint):

```text
postgresql://postgres.<project-ref>:<db-password>@aws-0-<region>.pooler.supabase.com:6543/postgres?sslmode=require
```

Notes:

- Prefer direct port `5432` for this test runner because it executes multiple statements and transaction-scoped checks.
- Username format matters:
  - direct host (`db.<project-ref>.supabase.co`) uses user `postgres`
  - pooler host (`aws-0-<region>.pooler.supabase.com`) uses user `postgres.<project-ref>`
- Keep `sslmode=require` in the DSN.
- URL-encode special characters in passwords (for example `@`, `:`, `/`, `?`, `#`, `%`).

## Step 1: Generate test specs

From repo root:

```bash
python scripts/generate_query_test_specs.py
```

This scans `queries/*.pgsql` and creates `tests/query_test_specs.json`.

Note: existing `custom_assertions` are preserved on regeneration, so your manual checks are not lost.

## Step 2: (Optional) Refine assertions per query

Open `tests/query_test_specs.json` and tune:

- `assertions.must_return_rows`
- `assertions.deliverable_keywords`
- `custom_assertions` (set `enabled: true` and add SQL returning `TRUE`/`FALSE`)

Example custom assertion:

```json
{
  "name": "a1_love_search_returns_rows",
  "sql": "SELECT EXISTS (SELECT 1 FROM public.track WHERE name ILIKE '%love%')",
  "enabled": true
}
```

## Step 3: Run tests and generate report

PowerShell example:

```powershell
$env:DATABASE_URL = "postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require"
python scripts/run_query_tests.py
```

One-command PowerShell wrapper:

```powershell
$env:DATABASE_URL = "postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require"
./scripts/run_query_tests.ps1
```

Or pass DSN explicitly:

```bash
python scripts/run_query_tests.py --dsn "postgresql://postgres:<db-password>@db.<project-ref>.supabase.co:5432/postgres?sslmode=require"
```

If your network cannot resolve the direct host, use the pooler DSN instead:

```bash
python scripts/run_query_tests.py --dsn "postgresql://postgres.<project-ref>:<db-password>@aws-0-<region>.pooler.supabase.com:6543/postgres?sslmode=require"
```

## Outputs

- `artifacts/query_test_report.md`: pass/fail table plus per-task check details.
- `artifacts/query_test_report.json`: same data in structured format for CI.

## CI idea

Add a workflow step:

```bash
python scripts/generate_query_test_specs.py
python scripts/run_query_tests.py --dsn "$DATABASE_URL"
```

Use the command exit code to fail CI when one or more query tests fail.
