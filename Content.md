# SQL Cookbook — Workplan & Sections

Purpose
- This checklist organizes the full set of SQL queries, DBA tasks, and exercises you'll implement for the Chinook "SQL Cookbook".
- Use the checkboxes to track progress. Each item includes a brief goal, suggested repo path(s), and a "definition of done" so you know when to mark it complete.

How to use
- Edit this file in VS Code and toggle the checkboxes as you finish items (on GitHub the boxes are interactive).
- For each completed item, commit with a short message, e.g.:
  - git add SECTIONS.md && git commit -m "Mark A1 complete: simple SELECTs and filters"
- Definition of Done (default for every checklist item):
  1. SQL file(s) committed to the repo (suggested path included).
  2. Example output saved (CSV or screenshot) in an `artifacts/` or `examples/` folder.
  3. Short explanation added to the query file or queries/README.md (1–3 lines).
  4. If relevant, a test added under `tests/` and passing in CI.

Recommended next steps (priority)
0. Create DB schema diagram (ERD) — generate an ER diagram from `migrations/001_create_schema.sql` or from a live DB and save it under `docs/` or `artifacts/` for reference.
1. Basics & Joins: A1–A4, B5–B8 — quick wins to populate queries/ and get CI to run.
2. Aggregations & Window Functions: C9–C12, D13–D16 — analytics-focused, high impact.
3. Indexing & EXPLAIN: G23, H27 — show performance improvements with before/after.
4. Materialized views & triggers: I30, P46 — ops + analytics features.
5. Add tests & CI to validate (R50, M40) so PR checks exercise your migrations/seeds/queries.

Checklist: sections and items

A. Basic queries (fundamentals)
- [ ] A1 — Simple SELECTs & filters (queries/001_select_filters.sql)
- [ ] A2 — DISTINCT and COUNT(DISTINCT) (queries/002_distinct_counts.sql)
- [ ] A3 — Pagination & keyset patterns (queries/003_pagination.sql)
- [ ] A4 — Casting, formatting, simple type conversions (queries/004_casts_formatting.sql)

B. Joins & relational queries
- [ ] B5 — Inner / Left / Right joins (queries/005_joins_basic.sql)
- [ ] B6 — Many-to-many joins (playlist ↔ tracks) (queries/006_many_to_many.sql)
- [ ] B7 — Anti-join / NOT EXISTS / NOT IN patterns (queries/007_anti_join.sql)
- [ ] B8 — Semi-join (EXISTS) patterns (queries/008_semi_join.sql)

C. Aggregation & grouping analysis
- [ ] C9 — GROUP BY & HAVING basics (queries/009_group_by.sql)
- [ ] C10 — ROLLUP / GROUPING SETS / CUBE examples (queries/010_grouping_sets.sql)
- [ ] C11 — FILTERed aggregates (Postgres) (queries/011_filter_aggregates.sql)
- [ ] C12 — Percentiles / distribution (ntile / percentile_cont) (queries/012_percentiles.sql)

D. Window functions & analytics
- [ ] D13 — ROW_NUMBER / RANK / DENSE_RANK examples (queries/013_rank_window.sql)
- [ ] D14 — LAG / LEAD (inter-event differences) (queries/014_lag_lead.sql)
- [ ] D15 — Running totals & moving averages (queries/015_running_totals.sql)
- [ ] D16 — Windowed percentiles / cume_dist / percent_rank (queries/016_window_percentiles.sql)

E. CTEs, recursive queries & advanced logic
- [ ] E17 — Simple CTEs for staging/clarity (queries/017_cte_staging.sql)
- [ ] E18 — Recursive CTE: employee manager chain (queries/018_recursive_cte.sql)
- [ ] E19 — Pivoting / crosstab (or FILTER-based pivot) (queries/019_pivot.sql)

F. Data transformation & cleaning
- [ ] F20 — Deduplication patterns (DISTINCT ON / window-based) (queries/020_dedup.sql)
- [ ] F21 — Normalization / splitting columns (migrations/021_normalize_composer.sql + queries/)
- [ ] F22 — NULL handling & coalesce fixes, update totals from invoices (queries/022_null_handling.sql)

G. Indexing & performance tuning (DBA)
- [ ] G23 — Create targeted indexes & benchmark (migrations/023_create_indexes.sql + analysis/023_index_benchmark.md)
- [ ] G24 — Expression indexes (e.g., lower(email)) (migrations/024_expr_index.sql)
- [ ] G25 — Partial indexes use-case (migrations/025_partial_index.sql)
- [ ] G26 — Functional/generated column index (migrations/026_functional_index.sql)

H. EXPLAIN, profiling & before/after comparisons
- [ ] H27 — EXPLAIN ANALYZE: save plan and annotate (analysis/027_explain_before.sql / _after.sql / .md)
- [ ] H28 — Query stats (pg_stat_statements) exploration (analysis/028_pg_stat_statements.md)
- [ ] H29 — Query rewrites and plan changes (queries/029_rewrite_for_performance.sql)

I. Materialized views, caching & pre-aggregation
- [ ] I30 — Materialized view for top-selling tracks (migrations/030_mv_top_tracks.sql + queries/030_query_mv.sql)
- [ ] I31 — Incremental refresh strategy notes (analysis/031_mv_refresh_strategy.md)

J. Transactions, concurrency & safe migrations
- [ ] J32 — Safe multi-step migrations (add column, backfill, swap) (migrations/032_safe_column_add.sql & docs/032_safe_migration.md)
- [ ] J33 — Isolation level demonstrations (tests/033_transactions_isolation.sql)
- [ ] J34 — Locking guidelines and advisory locks (docs/034_locking_guidelines.md)

K. Schema design, normalization & refactoring
- [ ] K35 — ER diagram and normalization/denormalization trade-offs (docs/035_er_diagram.svg + docs/035_tradeoffs.md)
- [ ] K36 — Partitioning design (concept + example) (docs/036_partitioning_design.md and optional migrations/036_partition_example.sql)

L. Security, roles & row-level policies
- [ ] L37 — Roles and GRANT examples (migrations/037_roles_and_grants.sql)
- [ ] L38 — Row-level security (RLS) example (migrations/038_rls_example.sql + docs/038_rls_notes.md)

M. Backup, restore & migration exercises (CI/CD)
- [ ] M39 — Backup & restore with pg_dump / pg_restore (scripts/039_backup_restore.sh + docs/039_backup_instructions.md)
- [ ] M40 — CI/CD: idempotent migration pipeline & tests (already scaffolded .github/workflows/deploy-migrations.yml)

N. Monitoring, observability & health checks
- [ ] N41 — Health check queries (pg_stat_activity, table stats) (scripts/041_health_checks.sql + docs/041_monitoring.md)
- [ ] N42 — Scheduled GitHub Action ping / simple alert (add .github/workflows/041_db_ping.yml)

O. Extensions & advanced Postgres features (if available)
- [ ] O43 — Full-text search demo (migrations/043_fulltext.sql + queries/043_fulltext_queries.sql)
- [ ] O44 — JSONB metadata usage and queries (migrations/044_jsonb_example.sql + queries/044_jsonb_queries.sql)
- [ ] O45 — PostGIS notes (if enabled) (docs/045_postgis_notes.md)

P. Stored procedures / triggers / auditing
- [ ] P46 — Audit trigger for invoice changes (migrations/046_audit_trigger.sql + queries/046_audit_queries.sql)
- [ ] P47 — Stored procedure to create invoice + items (migrations/047_invoice_proc.sql + tests/047_invoice_proc_test.sql)

Q. Concurrency, load & capacity planning (conceptual + practical)
- [ ] Q48 — Load test simulation and analysis (scripts/048_load_test.sh + analysis/048_load_results.md)

R. Data lineage, documentation & tests
- [ ] R49 — Document each query (queries/README.md: intent, tags, complexity)
- [ ] R50 — Add CI tests asserting expected counts/properties for key queries (tests/*.sql; pr-check.yml runs them)

Optional extras / polish
- [ ] Add screenshots or 60–90s demo video for 3 highlight items (artifacts/videos/)
- [ ] Provide a "Try this" quickstart on your portfolio page linking to saved Supabase SQL snippets or db-fiddle examples
- [ ] Add a "Cheat sheet" page summarizing common idioms (joins, window functions, CTEs) for quick reference (docs/CHEATSHEET.md)

Notes about ordering and dependency
- Many items are independent; you can implement in any order. For fastest visible progress, follow the "Recommended next steps" above.
- Some admin items (roles, partitioning) may require elevated privileges in Supabase. If your project account lacks permission, document the steps and show local/CI simulation.

"What's next" — immediate actions you can do right now
1. Generate the DB schema diagram first: parse `migrations/001_create_schema.sql` or connect to a test DB and produce `docs/035_er_diagram.svg` or `artifacts/chinook.png`.
2. In VS Code, create queries/001_select_filters.sql and commit a couple of simple SELECT examples. Mark A1 done.
3. Add queries/005_joins_basic.sql with a few join examples (tracks → albums → artists). Mark B5 done.
4. Open a PR with those files; the PR CI (pr-check.yml) will run smoke tests. If they pass, merge to main.
5. Then pick the aggregation/window set (C9–D16) to produce analytics-focused content.

If you'd like, I can:
- Generate the first 8 SQL files (A1–A4, B5–B8) with ready-to-run SQL and brief comments so you can paste them into queries/ and commit.
- Or create a short "queries/README.md" entry for each of the first 20 queries describing intent and expected output.

Which of those helper tasks would you like me to do next? (e.g., "Generate A1–A4 and B5–B6 SQL files")