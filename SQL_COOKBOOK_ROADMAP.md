# SQL Cookbook — Workplan & Detailed Tasks

Purpose
- An actionable checklist for the Chinook "SQL Cookbook". Each section contains the high-level task, then a concrete list of specific queries or activities you should implement so you know exactly what to build and commit.

Definition of Done (for each checkbox)
1. SQL file(s) added under the suggested path (e.g., `queries/###_name.sql` or `migrations/###_name.sql`).
2. Example output saved as CSV or a screenshot under `artifacts/` or `examples/`.
3. Short explanation (1–3 lines) added either at top of the SQL file or in `queries/README.md`.
4. If applicable, add a small test under `tests/` that verifies the query runs or returns expected structure/row count; CI passes.


---
**Legend: Main Topics & Progress**

| Section | Topic                                      | Status        |
|---------|--------------------------------------------|---------------|
| A       | Basic queries (fundamentals)               | ✅ Complete   |
| B       | Joins & relational queries                 | ✅ Complete   |
| C       | Aggregation & grouping analysis            | ✅ Complete   |
| D       | Window functions & analytics               | ✅ Complete   |
| E       | CTEs, recursive queries & advanced logic   | ⏳ In progress|
| F       | Data transformation & cleaning             | ❌ Not started|
| G       | Indexing & performance tuning (DBA)        | ❌ Not started|
| H       | EXPLAIN, profiling & comparisons           | ❌ Not started|
| I       | Materialized views, caching & pre-agg      | ❌ Not started|
| J       | Transactions, concurrency & migrations     | ❌ Not started|
| K       | Schema design, normalization & refactoring | ❌ Not started|
| L       | Security, roles & row-level policies       | ❌ Not started|
| M       | Backup, restore & migration exercises      | ❌ Not started|
| N       | Monitoring, observability & health checks  | ❌ Not started|
| O       | Extensions & advanced Postgres features    | ❌ Not started|
| P       | Stored procedures / triggers / auditing    | ❌ Not started|
| Q       | Concurrency, load & capacity planning      | ❌ Not started|
| R       | Data lineage, documentation & tests        | ❌ Not started|
| —       | Optional extras / polish                   | ❌ Not started|

---

Detailed checklist with expected queries / activities

A. Basic queries (fundamentals) ✅
- [x] A1 — Simple SELECTs & filters (queries/001_select_filters.sql)
  - Expected tasks:
    - Select specific columns: customers email + country.
    - Filter by equality and range: invoices where total > 10.
    - Use LIKE/ILIKE for substring matches: tracks with "love" in name.
    - Save 3 example result CSVs (country filter, price filter, text search).
- [x] A2 — DISTINCT and COUNT(DISTINCT) (queries/002_distinct_counts.sql)
  - Expected queries:
    - Count distinct billing_country in invoices.
    - List distinct genres present in tracks.
    - Show emails uniqueness check: COUNT(*) vs COUNT(DISTINCT email).
- [x] A3 — Pagination & keyset patterns (queries/003_pagination.sql)
  - Expected activities/queries:
    - Classic OFFSET/LIMIT pagination example:
      - SELECT track_id, name FROM tracks ORDER BY track_id LIMIT 20 OFFSET 40;
    - Keyset (cursor) pagination example (better performance):
      - SELECT track_id, name FROM tracks WHERE track_id > :last_seen_id ORDER BY track_id LIMIT 20;
    - Show how to page by date (e.g., invoice_date) using last-seen timestamp.
    - Explain pros/cons: OFFSET cost vs keyset stability.
- [x] A4 — Casting, formatting, simple type conversions (queries/004_casts_formatting.sql)
  - Expected tasks:
    - Format milliseconds to minutes/seconds: milliseconds/1000.0 AS seconds.
    - Cast numeric to integer/decimal and format currency with TO_CHAR(total, 'FM$999,999.00').
    - Parse/format dates: date_trunc('month', invoice_date).

B. Joins & relational queries ✅
- [x] B5 — Inner / Left / Right joins (queries/005_joins_basic.sql)
  - Expected queries:
    - Inner join tracks → albums → artists to show track + album + artist.
    - LEFT JOIN from albums to tracks to show albums with zero tracks.
    - Example RIGHT JOIN (or explain equivalence using LEFT JOIN by swapping tables).
- [x] B6 — Many-to-many joins (playlist ↔ tracks) (queries/006_many_to_many.sql)
  - Expected queries:
    - List tracks in a playlist (join playlist_track → tracks).
    - Tracks appearing in multiple playlists (group + HAVING COUNT(*) > 1).
- [x] B7 — Anti-join / NOT EXISTS / NOT IN patterns (queries/007_anti_join.sql)
  - Expected queries:
    - Customers without invoices (left join + WHERE invoices IS NULL).
    - Tracks never sold (tracks not in invoice_items).
    - Compare NOT EXISTS vs LEFT JOIN anti-join performance notes.
- [x] B8 — Semi-join (EXISTS) patterns (queries/008_semi_join.sql)
  - Expected queries:
    - Artists who have at least one track sold (EXISTS(SELECT 1 FROM ...)).
    - Use EXISTS for correlated existence checks vs joins that cause duplication.

C. Aggregation & grouping analysis ✅
- [x] C9 — GROUP BY & HAVING basics (queries/009_group_by.sql)
  - Expected queries:
    - Revenue per customer: SUM(invoices.total) grouped by customer.
    - Orders per country: COUNT(*) grouped by billing_country.
    - HAVING example: genres with revenue > X.
- [x] C10 — ROLLUP / GROUPING SETS / CUBE examples (queries/010_grouping_sets.sql)
  - Expected queries:
    - Monthly revenue by country + subtotals using GROUPING SETS or ROLLUP.
    - Demonstrate how grouping sets produce multi-level aggregates in one pass.
- [x] C11 — FILTERed aggregates (Postgres) (queries/011_filter_aggregates.sql)
  - Expected queries:
    - SUM(amount) FILTER (WHERE billing_country = 'USA') AS usa_revenue.
    - Conditional counts: COUNT(*) FILTER (WHERE quantity > 1) AS multi_item_sales.
- [x] C12 — Percentiles / distribution (ntile / percentile_cont) (queries/012_percentiles.sql)
  - Expected queries:
    - Use NTILE(4) over tracks ordered by unit_price to bucket by quartiles.
    - percentile_cont(0.5) WITHIN GROUP (ORDER BY unit_price) for median unit_price.

D. Window functions & analytics ✅
- [x] D13 — ROW_NUMBER / RANK / DENSE_RANK examples (queries/013_rank_window.sql)
  - Expected queries:
    - Top track per genre using ROW_NUMBER() PARTITION BY genre ORDER BY times_sold DESC.
    - Tie-aware ranking with RANK() and DENSE_RANK().
- [x] D14 — LAG / LEAD (inter-event differences) (queries/014_lag_lead.sql)
  - Expected queries:
    - For each customer, compute days between consecutive invoices: invoice_date - LAG(invoice_date).
    - Use LEAD to peek next invoice per customer.
- [x] D15 — Running totals & moving averages (queries/015_running_totals.sql)
  - Expected queries:
    - Running total of customer spend: SUM(total) OVER (PARTITION BY customer_id ORDER BY invoice_date).
    - 7-day rolling revenue using RANGE or ROWS BETWEEN.
- [x] D16 — Windowed percentiles / cume_dist / percent_rank (queries/016_window_percentiles.sql)
  - Expected queries:
    - Compute PERCENT_RANK of customers by total_spent to identify top percentiles.
    - CUME_DIST for cumulative distribution across tracks by unit_price.

E. CTEs, recursive queries & advanced logic ⏳ (in progress)
- [ ] E17 — Simple CTEs for staging/clarity (queries/017_cte_staging.sql)
  - Expected activities:
    - Rewrite a multi-join aggregation as one or more CTEs (staging -> aggregation).
    - Use WITH to compute sub-aggregates and then join them.
- [ ] E18 — Recursive CTE: employee manager chain (queries/018_recursive_cte.sql)
  - Expected queries:
    - Use WITH RECURSIVE to expand reports_to chain from a given employee up to top manager.
    - Show path length and level. Provide output example.
- [ ] E19 — Pivoting / crosstab (or FILTER-based pivot) (queries/019_pivot.sql)
  - Expected tasks:
    - Pivot monthly revenue into columns for a small range of months (use FILTER or crosstab extension).
    - If crosstab not available, show manual pivot with SUM(...) FILTER (WHERE date_trunc('month', invoice_date) = '2024-01-01').

F. Data transformation & cleaning ❌ (not started)
- [ ] F20 — Deduplication patterns (DISTINCT ON / window-based) (queries/020_dedup.sql)
  - Expected queries:
    - Find duplicate customers by (first_name, last_name, email) and show canonical pick using ROW_NUMBER().
    - Provide cleanup example: DELETE FROM ... WHERE ctid IN (SELECT ctid FROM ... WHERE row_number > 1).
- [ ] F21 — Normalization / splitting columns (migrations/021_normalize_composer.sql + queries/)
  - Expected activities:
    - Extract composer into composer_first and composer_last (string split) as a migration + backfill.
    - Show SELECTs before and after normalization.
- [ ] F22 — NULL handling & coalesce fixes, update totals from invoices (queries/022_null_handling.sql)
  - Expected queries:
    - Recompute customers.total_spent from invoices and update table with COALESCE sums.
    - Example: UPDATE customers SET total_spent = COALESCE((SELECT SUM(total) FROM invoices WHERE customer_id = customers.customer_id),0);

G. Indexing & performance tuning (DBA) ❌ (not started)
- [ ] G23 — Create targeted indexes & benchmark (migrations/023_create_indexes.sql + analysis/023_index_benchmark.md)
  - Expected tasks:
    - Create an index on invoices(invoice_date) and/or invoice_items(track_id).
    - Measure a sample query before/after with EXPLAIN ANALYZE and record elapsed times.
- [ ] G24 — Expression indexes (e.g., lower(email)) (migrations/024_expr_index.sql)
  - Expected tasks/queries:
    - Create INDEX ON LOWER(customers.email) and show case-insensitive search improvement.
    - Provide example: SELECT * FROM customers WHERE LOWER(email) = 'alice@example.com';
- [ ] G25 — Partial indexes use-case (migrations/025_partial_index.sql)
  - Expected tasks:
    - Create a partial index e.g., ON invoices(invoice_date) WHERE total > 100.
    - Explain when partial indexes help and show a query that benefits.
- [ ] G26 — Functional/generated column index (migrations/026_functional_index.sql)
  - Expected tasks:
    - Create an index on (date_trunc('month', invoice_date)) or on an expression used frequently.
    - Show how to query to take advantage of the functional index.

H. EXPLAIN, profiling & before/after comparisons ❌ (not started)
- [ ] H27 — EXPLAIN ANALYZE: save plan and annotate (analysis/027_explain_before.sql / _after.sql / .md)
  - Expected activities:
    - Pick one slow-ish query (e.g., top tracks by sales join) and run EXPLAIN ANALYZE.
    - Identify seq scan, nested loops, expensive nodes; apply an index or rewrite and re-run EXPLAIN ANALYZE.
    - Save both plans and write a short note describing the change.
- [ ] H28 — Query stats (pg_stat_statements) exploration (analysis/028_pg_stat_statements.md)
  - Expected tasks:
    - If extension available, show top 10 queries by total_time and suggest optimizations.
- [ ] H29 — Query rewrites and plan changes (queries/029_rewrite_for_performance.sql)
  - Expected tasks:
    - Re-express a correlated subquery as a JOIN (or vice versa) and compare plans.

I. Materialized views, caching & pre-aggregation ❌ (not started)
- [ ] I30 — Materialized view for top-selling tracks (migrations/030_mv_top_tracks.sql + queries/030_query_mv.sql)
  - Expected tasks:
    - CREATE MATERIALIZED VIEW mv_top_tracks AS ... and demonstrate REFRESH MATERIALIZED VIEW CONCURRENTLY and query.
    - Show use-case: speed up repeated heavy aggregation.
- [ ] I31 — Incremental refresh strategy notes (analysis/031_mv_refresh_strategy.md)
  - Expected activities:
    - Document when to refresh (schedule, event-driven), cost/latency tradeoffs, and sample SQL to refresh only recent partitions if you partition the base table.

J. Transactions, concurrency & safe migrations ❌ (not started)
- [ ] J32 — Safe multi-step migrations (add column, backfill, swap) (migrations/032_safe_column_add.sql & docs/032_safe_migration.md)
  - Expected tasks:
    - Implement 3-step pattern: add nullable column, backfill in batches, set NOT NULL and drop old column.
    - Provide scripts or example SQL for each step and a note about downtime risk.
- [ ] J33 — Isolation level demonstrations (tests/033_transactions_isolation.sql)
  - Expected activities:
    - Demonstrate phantom/read phenomena using two sessions and different isolation levels.
    - Save simple scripts showing behavior under READ COMMITTED vs REPEATABLE READ.
- [ ] J34 — Locking guidelines and advisory locks (docs/034_locking_guidelines.md)
  - Expected tasks:
    - Provide example of pg_advisory_lock usage to coordinate migrations or maintenance.

K. Schema design, normalization & refactoring ❌ (not started)
- [ ] K35 — ER diagram and normalization/denormalization trade-offs (docs/035_er_diagram.svg + docs/035_tradeoffs.md)
  - Expected tasks:
    - Produce a small ER diagram (draw.io export) and write 1 paragraph about normalization level and any denormalization choices for analytics.
- [ ] K36 — Partitioning design (concept + example) (docs/036_partitioning_design.md and optional migrations/036_partition_example.sql)
  - Expected activities:
    - Document a plan to partition invoices by year/month; include example CREATE TABLE ... PARTITION BY RANGE and an example of inserting to partition.
    - If Supabase does not allow partition DDL in your plan, include the example as documentation and local test script.

L. Security, roles & row-level policies ❌ (not started)
- [ ] L37 — Roles and GRANT examples (migrations/037_roles_and_grants.sql)
  - Expected tasks:
    - Create a reporting_role with SELECT privileges on reporting tables and show GRANT statements.
- [ ] L38 — Row-level security (RLS) example (migrations/038_rls_example.sql + docs/038_rls_notes.md)
  - Expected activities:
    - Create a tenant_id example column and a simple RLS policy for tenant isolation; demonstrate session with set_config('app.tenant', 't1', false) or explain how to set current_user-based policy.

M. Backup, restore & migration exercises (CI/CD) ❌ (not started)
- [ ] M39 — Backup & restore with pg_dump / pg_restore (scripts/039_backup_restore.sh + docs/039_backup_instructions.md)
  - Expected tasks:
    - Provide commands for schema-only dump and full dump, restore into a fresh DB, and verify object counts.
- [ ] M40 — CI/CD: idempotent migration pipeline & tests (already scaffolded)
  - Expected activities:
    - Ensure `pr-check.yml` runs migrations and tests; add at least one test that asserts a critical table exists and has rows.

N. Monitoring, observability & health checks ❌ (not started)
- [ ] N41 — Health check queries (pg_stat_activity, table stats) (scripts/041_health_checks.sql + docs/041_monitoring.md)
  - Expected queries:
    - SELECT count(*) FROM pg_stat_activity WHERE state = 'active';
    - Basic table bloat / row count checks: SELECT relname, n_live_tup FROM pg_stat_user_tables;
- [ ] N42 — Scheduled GitHub Action ping / simple alert (add .github/workflows/041_db_ping.yml)
  - Expected activities:
    - Create a scheduled workflow that runs a simple SELECT 1 or SELECT count(*) FROM customers and fails if slow (> X seconds).

O. Extensions & advanced Postgres features (if available) ❌ (not started)
- [ ] O43 — Full-text search demo (migrations/043_fulltext.sql + queries/043_fulltext_queries.sql)
  - Expected tasks:
    - Create a tsvector column for tracks (name || ' ' || composer) and an index: CREATE INDEX ON tracks USING GIN (to_tsvector('english', name || ' ' || composer)).
    - Queries: simple @@ search and ranking with ts_rank.
- [ ] O44 — JSONB metadata usage and queries (migrations/044_jsonb_example.sql + queries/044_jsonb_queries.sql)
  - Expected tasks:
    - Add jsonb metadata column to tracks, insert sample JSON, and query nested fields with ->> and jsonb_path_query.
- [ ] O45 — PostGIS notes (if enabled) (docs/045_postgis_notes.md)
  - Expected activities:
    - Document how you would use PostGIS for geo-joins if you extended dataset (not required for Chinook).

P. Stored procedures / triggers / auditing ❌ (not started)
- [ ] P46 — Audit trigger for invoice changes (migrations/046_audit_trigger.sql + queries/046_audit_queries.sql)
  - Expected tasks:
    - Create invoice_audit table and trigger function that logs INSERT/UPDATE/DELETE with old/new JSONB.
    - Demonstrate querying audit trail for a single invoice id.
- [ ] P47 — Stored procedure to create invoice + items (migrations/047_invoice_proc.sql + tests/047_invoice_proc_test.sql)
  - Expected activities:
    - Write a plpgsql function create_invoice(customer_id, items jsonb) that inserts into invoices and invoice_items in a transaction.
    - Add a test that calls the function and asserts invoice + items exist and totals match.

Q. Concurrency, load & capacity planning (conceptual + practical) ❌ (not started)
- [ ] Q48 — Load test simulation and analysis (scripts/048_load_test.sh + analysis/048_load_results.md)
  - Expected tasks:
    - Use a simple script or pgbench-like loop to simulate many SELECTs or INSERTs and record response times.
    - Document observed behavior and recommendations (indexes, connection pooling).

R. Data lineage, documentation & tests ❌ (not started)
- [ ] R49 — Document each query (queries/README.md: intent, tags, complexity)
  - Expected activities:
    - Add a `queries/README.md` with a one-line description and tags (beginner/advanced/window/indexing) for each query file.
- [ ] R50 — Add CI tests asserting expected counts/properties for key queries (tests/*.sql; pr-check.yml runs them)
  - Expected tasks:
    - Add tests that assert customers.total_spent >= 0, invoices table has > 0 rows, mv_top_tracks exists after refresh, etc.

Optional extras / polish ❌ (not started)
- [ ] Add screenshots or 60–90s demo video for 3 highlight items (artifacts/videos/)
- [ ] Provide a "Try this" quickstart on your portfolio linking to saved Supabase SQL snippets or db-fiddle examples
- [ ] Add a "Cheat sheet" page summarizing common idioms (joins, window functions, CTEs) (docs/CHEATSHEET.md)