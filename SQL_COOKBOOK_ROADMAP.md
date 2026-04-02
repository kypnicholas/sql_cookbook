# SQL Cookbook — Workplan & Detailed Tasks

Purpose
- An actionable checklist for the Chinook Dataset "SQL Cookbook". Each section contains the high-level task, then a list of specific queries or activities to implement.

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

- [ ] E17 — Simple CTEs for staging/clarity (queries/017_standalone_cte.sql)
  - Identify an existing query (e.g., total sales per artist joining tracks, albums, invoice_items) that uses multiple joins and aggregations.
  - Rewrite this query using at least two CTEs:
    - First CTE: Stage a join between tracks, albums, and artists.
    - Second CTE: Aggregate sales (SUM(invoice_items.unit_price * invoice_items.quantity)) per artist.
    - Final SELECT: Join the CTEs to produce the final result.
  - Add a comment explaining why CTEs improve clarity or maintainability.


- [ ] E18 — Recursive CTE: employee management chain (queries/018_recursive_cte.sql)
  - Write a query using WITH RECURSIVE to list the management chain for a given employee (start with an employee_id), using the reports_to column in the employee table.
  - Output should include: employee_id, reports_to, level (distance from top), and a concatenated path of names.
  - Provide an example result for one employee.

- [ ] E19 — Pivoting / crosstab (or FILTER-based pivot) (queries/019_pivot.sql)
  - Use the crosstab extension (if available) to pivot monthly revenue into columns for at least three months.
  - If crosstab is not available, use SUM(...) FILTER (WHERE ...) to manually pivot revenue for three specific months into columns.
  - Add a comment showing both approaches and when to use each.

F. Data transformation & cleaning ❌ (not started)

- [ ] F20 — Deduplication patterns (DISTINCT ON / window-based) (queries/020_dedup.sql)
  - Write a query to find duplicate customers based on (first_name, last_name, email).
  - Use ROW_NUMBER() OVER (PARTITION BY first_name, last_name, email ORDER BY customer_id) to identify duplicates.
  - Write a DELETE statement to remove duplicates, keeping only the lowest customer_id per group.

- [ ] F21 — Normalization / splitting columns (migrations/021_normalize_composer.sql + queries/)
  - Write a migration to add composer_first and composer_last columns to the track table.
  - Write an UPDATE statement to split the composer field into first and last names (using SPLIT_PART or similar).
  - Write SELECT queries to show before/after normalization.

- [ ] F22 — NULL handling & coalesce fixes, update totals from invoices (queries/022_null_handling.sql)
  - Write a query to recompute customer total_spent using COALESCE to handle NULLs (note: the Chinook schema does not have a total_spent column by default, so this may require an ALTER TABLE or a view).
  - Write an UPDATE statement to set customers.total_spent to the sum of their invoices, defaulting to 0 if no invoices exist (if you add the column).

G. Indexing & performance tuning (DBA) ❌ (not started)

- [ ] G23 — Create targeted indexes & benchmark (migrations/023_create_indexes.sql + analysis/023_index_benchmark.md)
  - Create an index on invoice(invoice_date).
  - Create an index on invoice_line(track_id).
  - Run EXPLAIN ANALYZE on a query filtering by invoice_date before and after the index; record and compare timings.

- [ ] G24 — Expression indexes (e.g., lower(email)) (migrations/024_expr_index.sql)
  - Create an index on LOWER(customer.email).
  - Write a query to search for a customer by email case-insensitively and show the index is used (EXPLAIN).

- [ ] G25 — Partial indexes use-case (migrations/025_partial_index.sql)
  - Create a partial index on invoice(invoice_date) WHERE total > 100.
  - Write a query that benefits from this index and show the plan.

- [ ] G26 — Functional/generated column index (migrations/026_functional_index.sql)
  - Create an index on date_trunc('month', invoice_date) on the invoice table.
  - Write a query that groups by month and show the index is used.

H. EXPLAIN, profiling & before/after comparisons ❌ (not started)

- [ ] H27 — EXPLAIN ANALYZE: save plan and annotate (analysis/027_explain_before.sql / _after.sql / .md)
  - Pick a slow query (e.g., top tracks by sales with joins, using the invoice_line and track tables).
  - Run EXPLAIN ANALYZE and save the plan.
  - Apply an optimization (e.g., add an index or rewrite the query).
  - Run EXPLAIN ANALYZE again and save the new plan.
  - Write a short note comparing the two plans.

- [ ] H28 — Query stats (pg_stat_statements) exploration (analysis/028_pg_stat_statements.md)
  - Query pg_stat_statements for the top 10 queries by total_time (if the extension is available in your environment).
  - Suggest one optimization for a slow query based on the stats.

- [ ] H29 — Query rewrites and plan changes (queries/029_rewrite_for_performance.sql)
  - Take a correlated subquery and rewrite it as a JOIN (using actual Chinook tables, e.g., invoice, customer, invoice_line).
  - Take a JOIN and rewrite it as a correlated subquery.
  - Run EXPLAIN on both and compare the plans.

I. Materialized views, caching & pre-aggregation ❌ (not started)

- [ ] I30 — Materialized view for top-selling tracks (migrations/030_mv_top_tracks.sql + queries/030_query_mv.sql)
  - Write a CREATE MATERIALIZED VIEW statement for top-selling tracks (track_id, total_sales) using the track and invoice_line tables.
  - Write a query to REFRESH MATERIALIZED VIEW CONCURRENTLY.
  - Write a SELECT to query the materialized view for the top 10 tracks.
  - Add a comment explaining the performance benefit.

- [ ] I31 — Incremental refresh strategy notes (analysis/031_mv_refresh_strategy.md)
  - Document at least two strategies for refreshing materialized views (e.g., scheduled vs event-driven).
  - Provide sample SQL to refresh only recent partitions if partitioning is used (if you have partitioned tables in your schema).

J. Transactions, concurrency & safe migrations ❌ (not started)

- [ ] J32 — Safe multi-step migrations (add column, backfill, swap) (migrations/032_safe_column_add.sql & docs/032_safe_migration.md)
  - Write SQL to add a new nullable column to a table (e.g., add a column to the customer or track table).
  - Write a script to backfill the column in batches (using UPDATE with LIMIT/OFFSET or a loop).
  - Write SQL to set the column NOT NULL and drop the old column.
  - Document the steps and risks.

- [ ] J33 — Isolation level demonstrations (tests/033_transactions_isolation.sql)
  - Write scripts to demonstrate phantom/read phenomena using two sessions and different isolation levels (using tables like invoice or customer).
  - Save scripts for READ COMMITTED and REPEATABLE READ, showing the difference in results.

- [ ] J34 — Locking guidelines and advisory locks (docs/034_locking_guidelines.md)
  - Write an example using pg_advisory_lock to coordinate a migration or maintenance task.
  - Document when and why to use advisory locks.

K. Schema design, normalization & refactoring ❌ (not started)

- [ ] K35 — ER diagram and normalization/denormalization trade-offs (docs/035_er_diagram.svg + docs/035_tradeoffs.md)
  - Create a small ER diagram for the Chinook schema (use draw.io or similar).
  - Write a paragraph discussing normalization level and any denormalization choices, referencing actual Chinook tables and relationships.

- [ ] K36 — Partitioning design (concept + example) (docs/036_partitioning_design.md and optional migrations/036_partition_example.sql)
  - Document a plan to partition the invoice table by year/month.
  - Provide example CREATE TABLE ... PARTITION BY RANGE SQL for the invoice table.
  - Write an example INSERT into a partitioned invoice table.

L. Security, roles & row-level policies ❌ (not started)

- [ ] L37 — Roles and GRANT examples (migrations/037_roles_and_grants.sql)
  - Write SQL to create a reporting_role.
  - Write GRANT statements to give SELECT privileges on reporting tables (e.g., invoice, customer, track) to the role.

- [ ] L38 — Row-level security (RLS) example (migrations/038_rls_example.sql + docs/038_rls_notes.md)
  - Add a tenant_id column to a table (e.g., customer or invoice).
  - Write a CREATE POLICY statement for tenant isolation.
  - Demonstrate setting the session variable and querying as a tenant.

M. Backup, restore & migration exercises (CI/CD) ❌ (not started)

- [ ] M39 — Backup & restore with pg_dump / pg_restore (scripts/039_backup_restore.sh + docs/039_backup_instructions.md)
  - Write shell commands for schema-only and full database dumps.
  - Write commands to restore into a fresh database.
  - Write a query to verify object counts after restore (e.g., count rows in invoice, customer, track, etc.).

- [ ] M40 — CI/CD: idempotent migration pipeline & tests (already scaffolded)
  - Ensure pr-check.yml runs migrations and tests.
  - Add a test that asserts a critical table exists and has rows (e.g., invoice, customer, track).

N. Monitoring, observability & health checks ❌ (not started)

- [ ] N41 — Health check queries (pg_stat_activity, table stats) (scripts/041_health_checks.sql + docs/041_monitoring.md)
  - Write a query to count active connections from pg_stat_activity.
  - Write a query to check table bloat or row counts from pg_stat_user_tables (for tables like invoice, customer, track).

- [ ] N42 — Scheduled GitHub Action ping / simple alert (add .github/workflows/041_db_ping.yml)
  - Create a GitHub Actions workflow that runs a simple SELECT 1 or SELECT count(*) FROM customer.
  - Set the workflow to fail if the query is slow or fails.

O. Extensions & advanced Postgres features (if available) ❌ (not started)

- [ ] O43 — Full-text search demo (migrations/043_fulltext.sql + queries/043_fulltext_queries.sql)
  - Add a tsvector column to track and create a GIN index.
  - Write queries using @@ and ts_rank to search and rank tracks.

- [ ] O44 — JSONB metadata usage and queries (migrations/044_jsonb_example.sql + queries/044_jsonb_queries.sql)
  - Add a jsonb metadata column to track.
  - Insert sample JSON data.
  - Write queries to extract nested fields and use jsonb_path_query.

- [ ] O45 — PostGIS notes (if enabled) (docs/045_postgis_notes.md)
  - Document how PostGIS could be used for geo-joins if the dataset were extended (e.g., for customer or invoice locations).

P. Stored procedures / triggers / auditing ❌ (not started)

- [ ] P46 — Audit trigger for invoice changes (migrations/046_audit_trigger.sql + queries/046_audit_queries.sql)
  - Create an invoice_audit table.
  - Write a trigger function to log INSERT/UPDATE/DELETE with old/new JSONB.
  - Write a query to retrieve audit logs for a specific invoice.

- [ ] P47 — Stored procedure to create invoice + items (migrations/047_invoice_proc.sql + tests/047_invoice_proc_test.sql)
  - Write a plpgsql function create_invoice(customer_id, items jsonb) that inserts into invoice and invoice_line in a transaction.
  - Write a test that calls the function and checks that invoice and items exist and totals match.

- [ ] Q48 — Simulate concurrent inserts/updates (scripts/048_concurrency_test.sql)
  - Write a script to simulate concurrent inserts or updates to a table (e.g., invoice, customer, track).
  - Measure and record any deadlocks or contention.

- [ ] Q49 — Estimate table growth and storage needs (docs/049_capacity_planning.md)
  - Write a query to estimate current table sizes (e.g., invoice, customer, track).
  - Project growth based on recent insert rates.

Q. Concurrency, load & capacity planning (conceptual + practical) ❌ (not started)
- [ ] Q48 — Load test simulation and analysis (scripts/048_load_test.sh + analysis/048_load_results.md)
  - Expected tasks:
    - Use a simple script or pgbench-like loop to simulate many SELECTs or INSERTs and record response times.
    - Document observed behavior and recommendations (indexes, connection pooling).

R. Data lineage, documentation & tests ❌ (not started)

- [ ] R50 — Document query lineage for a report (docs/050_lineage_example.md)
  - Pick a report query and document the source tables and transformations (using actual Chinook tables).
  - Draw a simple lineage diagram.

- [ ] R51 — Add tests for critical queries (tests/051_query_tests.sql)
  - Write tests that check row counts, expected values, or structure for at least two important queries (using actual Chinook data).
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
