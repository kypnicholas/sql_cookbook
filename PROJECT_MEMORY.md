# Project Memory — sql_cookbook

> Assessed 2026-11-09 against repository `main` commit `949ad1e218c32114ba0a32402893712b697713f0`. This document describes verified source-controlled behavior, not a guarantee about external service settings or live deployment. When in doubt, inspect current code and deployment configuration.

## Purpose and status

A public learning and portfolio project for progressively more advanced PostgreSQL concepts using the Chinook sample music database on Supabase.

The authoritative task/progress checklist is [`SQL_COOKBOOK_ROADMAP.md`](SQL_COOKBOOK_ROADMAP.md). At assessment, sections A–G are labelled complete, H (EXPLAIN/performance comparison) is in progress, and later sections are not yet started. **Do not treat checklist labels as proof that a live database has been tested in this review.**

## Repository structure

- [`queries/`](queries/): numbered `.pgsql` and SQL exercises covering selection, joins, aggregates, windows, recursion, cleanup, index design and EXPLAIN.
- [`migrations/`](migrations/): schema creation and database alteration/index experiments.
- [`seeds/`](seeds/): Chinook sample data and additional seed scripts.
- [`analysis/`](analysis/): EXPLAIN/index observations and benchmark notes.
- [`scripts/generate_query_test_specs.py`](scripts/generate_query_test_specs.py): derives test specifications from query metadata, retaining custom assertions.
- [`scripts/run_query_tests.py`](scripts/run_query_tests.py) and [`scripts/run_query_tests.ps1`](scripts/run_query_tests.ps1): query execution and result reporting.
- [`tests/README.md`](tests/README.md): test architecture, Python/driver requirements and safe placeholder DSNs. [`tests/query_test_specs.json`](tests/query_test_specs.json) captures configured checks.
- [`artifacts/`](artifacts/): previously generated human-readable and JSON report outputs; not proof of current database state.

## Test and development approach

- Inspect tasks in `SQL_COOKBOOK_ROADMAP.md`; implement each numbered exercise in `queries/`, using sample schema and data as evidence.
- Generate query specs with `python scripts/generate_query_test_specs.py`, then (when a non-sensitive `DATABASE_URL` is configured) run `python scripts/run_query_tests.py`.
- Use `tests/README.md` for PostgreSQL driver installation, SQL assertions, DSN options and report generation.
- The test runner requires a reachable database; no live Supabase execution was attempted during this memory update.

## Scheduled automation and security

- [`.github/workflows/supabase-keepalive.yml`](.github/workflows/supabase-keepalive.yml) defines a scheduled/manual REST request against a Supabase sample table using configured GitHub secrets. Its existence does not establish recent successful execution.
- **Never** commit actual credentials, service-role secrets, private connection strings or personal data.
- Database constraints and SQL syntax must be tested in the intended PostgreSQL environment rather than assumed from local text.

## Memory maintenance

Treat this as a durable, concise navigation map rather than a work diary. Verify any claim against the relevant source files before acting. Propose changes for approval when implementation contracts, architecture or deployment behavior change. Never copy secrets, private user data or runtime records into this file.
