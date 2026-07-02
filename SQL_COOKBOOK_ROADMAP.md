# SQL Cookbook - Workplan and Detailed Tasks

## Purpose
- Keep one clear task list for learning advanced SQL on the Chinook dataset in Supabase.
- Preserve 1:1 mapping between completed tasks and existing solution files.
- Make pending tasks explicit, testable, and easy to implement incrementally.

## Ground Rules
- Query files in this repo use `.pgsql` under `queries/`.
- Migration files use `.sql` under `migrations/`.
- Use Chinook Postgres table names as they exist in this project (for example: `customer`, `invoice`, `invoice_line`, `track`, `album`, `artist`).
- Keep completed task IDs stable (A1 through D16) so existing solutions stay aligned.

## Definition of Done (per checkbox)
1. The file at the specified path exists and runs in Supabase SQL editor.
2. At least one representative result is saved (CSV or screenshot) under `artifacts/` or `examples/`.
3. A short note (1 to 3 lines) explains query intent at the top of the SQL file or in `queries/README.md`.
4. For mutation/performance tasks, include a small verification query under `tests/` when practical.

---

## Legend: Topics and Progress


| Section | Topic                                            | Progress       |
| ------- | ------------------------------------------------ | -------------- |
| A       | Basic queries (fundamentals)                     | **100% (4/4)** |
| B       | Joins and relational queries                     | **100% (4/4)** |
| C       | Aggregation and grouping analysis                | **100% (4/4)** |
| D       | Window functions and analytics                   | **100% (4/4)** |
| E       | CTEs, recursive queries, and advanced logic      | **100% (3/3)** |
| F       | Data transformation and cleaning                 | **67% (2/3)**  |
| G       | Indexing and performance tuning (DBA)            | **0% (0/4)**   |
| H       | EXPLAIN, profiling, and comparisons              | **0% (0/3)**   |
| I       | Materialized views, caching, and pre-aggregation | **0% (0/2)**   |
| J       | Transactions, concurrency, and safe migrations   | **0% (0/3)**   |
| K       | Schema design, normalization, and refactoring    | **0% (0/2)**   |
| L       | Security, roles, and row-level policies          | **0% (0/2)**   |
| M       | Backup, restore, and migration exercises         | **0% (0/2)**   |
| N       | Monitoring, observability, and health checks     | **0% (0/2)**   |
| O       | Extensions and advanced Postgres features        | **0% (0/3)**   |
| P       | Stored procedures, triggers, and auditing        | **0% (0/2)**   |
| Q       | Concurrency, load, and capacity planning         | **0% (0/2)**   |
| R       | Data lineage, documentation, and tests           | **0% (0/4)**   |
| X       | Optional extras and polish                       | **0% (0/3)**   |


---

## Detailed Checklist

### A. Basic Queries (Fundamentals) - Complete

- [x] A1 - Simple SELECTs and filters (`queries/001_select_filters.pgsql`)
  - Deliverable A: Base exploration queries on `album` and `artist` plus filtered customer projection by country.
  - Deliverable B: Numeric filter query for invoices with `total > 5.00`.
  - Deliverable C: Case-insensitive text search for tracks containing "love" using `ILIKE`.
  - Verification: All deliverables are implemented in the file and return expected rows in Supabase.

- [x] A2 - DISTINCT and COUNT(DISTINCT) (`queries/002_distinct_counts.pgsql`)
  - Deliverable A: Distinct transaction counts by `billing_country`.
  - Deliverable B: Distinct genre listing from `genre`.
  - Deliverable C: Email uniqueness check (`COUNT(*)` vs `COUNT(DISTINCT email)`).
  - Verification: Query outputs show category-level distinctness and identity-level uniqueness metrics.

- [x] A3 - Pagination and keyset patterns (`queries/003_pagination.pgsql`)
  - Deliverable A: LIMIT/OFFSET pagination examples ordered by `invoice_id`.
  - Deliverable B: Keyset pagination with `invoice_id` and composite-key variants.
  - Deliverable C: Date-based pagination over `invoice_date`.
  - Verification: File demonstrates both pagination strategies and includes explanatory notes on tradeoffs.

- [x] A4 - Casting, formatting, and simple type conversions (`queries/004_casts_formatting.pgsql`)
  - Deliverable A: Numeric casts on invoice totals using both `CAST(...)` and `::` syntax.
  - Deliverable B: Currency formatting with `TO_CHAR`.
  - Deliverable C: Track duration conversion from milliseconds to minute/second fields.
  - Verification: Output includes original and converted representations for each conversion case.

### B. Joins and Relational Queries - Complete

- [x] B5 - INNER and LEFT joins (`queries/005_joins_basic.pgsql`)
  - Deliverable A: INNER JOIN path `track -> album -> artist` for track metadata.
  - Deliverable B: LEFT JOIN `album -> track` to surface albums without tracks.
  - Deliverable C: Join-plus-aggregation example (track counts by artist/album).
  - Verification: Results include joined entities, null-preserving rows, and grouped summaries.

- [x] B6 - Many-to-many joins (`queries/006_many_to_many.pgsql`)
  - Deliverable A: Playlist track listing through `playlist_track` bridge joins.
  - Deliverable B: Multi-playlist track detection using `HAVING COUNT(*) > 1`.
  - Deliverable C: Playlist aggregation per track via `array_agg`.
  - Verification: File shows both row-level relationship traversal and grouped many-to-many summaries.

- [x] B7 - Anti-join patterns (`queries/007_anti_join.pgsql`)
  - Deliverable A: Customer anti-join via `LEFT JOIN ... IS NULL`.
  - Deliverable B: Equivalent customer anti-join via `NOT EXISTS`.
  - Deliverable C: Unsold-track anti-join in both forms.
  - Verification: Logical anti-join patterns are implemented in `queries/007_anti_join.pgsql`; plan benchmarking support exists in `queries/007_anti_join_perf.pgsql` with notes in `queries/007_anti_join_perf_explain.md`.

- [x] B8 - Semi-join (EXISTS) patterns (`queries/008_semi_join.pgsql`)
  - Deliverable A: `EXISTS` semi-join to identify artists with at least one sold track.
  - Deliverable B: Side-by-side comparison of duplicate-prone JOIN output versus `EXISTS` and `IN` checks.
  - Deliverable C: Aggregated playlist listing per track as a deduplicated result pattern.
  - Verification: File demonstrates existence testing patterns and their effect on row duplication.

### C. Aggregation and Grouping Analysis - Complete

- [x] C9 - GROUP BY and HAVING basics (`queries/009_group_by.pgsql`)
  - Deliverable A: Revenue per customer grouped by customer identity columns.
  - Deliverable B: Order count and revenue by customer country.
  - Deliverable C: Genre revenue from line-level sales (`invoice_line.unit_price * quantity`) filtered with `HAVING > 100`.
  - Verification: File contains all three grouped analyses and uses a non-overcounting genre revenue calculation.

- [x] C10 - ROLLUP, GROUPING SETS, and CUBE (`queries/010_grouping_sets.pgsql`)
  - Deliverable A: Monthly-country-state detail with subtotals via `ROLLUP`.
  - Deliverable B: Equivalent multidimensional subtotal output via `CUBE`.
  - Deliverable C: Explicit subtotal control using `GROUPING SETS` plus labeled subtotal rows.
  - Verification: All three operators are implemented in one file; companion explanation notes are in `queries/010_grouping_sets_combinations_explain.md`.

- [x] C11 - FILTER aggregates (`queries/011_filter_aggregates.pgsql`)
  - Deliverable A: Baseline aggregate with `WHERE` filtering.
  - Deliverable B: Multi-condition revenue aggregates using `FILTER` in one query.
  - Deliverable C: Conditional count breakdown using `FILTER`.
  - Verification: Outputs show single-pass conditional aggregate patterns for both sums and counts.

- [x] C12 - Percentiles and distribution (`queries/012_percentiles.pgsql`)
  - Deliverable A: `NTILE(4)` quartile assignment for track prices.
  - Deliverable B: Quartile-level summary stats (count, min, max, average).
  - Deliverable C: Quartile cut points and median using `percentile_cont`.
  - Verification: File includes both row-level bucketing and aggregate percentile summaries.

### D. Window Functions and Analytics - Complete

- [x] D13 - ROW_NUMBER, RANK, DENSE_RANK (`queries/013_rank_window.pgsql`)
  - Deliverable A: Top-selling tracks per genre with `RANK()`.
  - Deliverable B: Tie-dense variant with `DENSE_RANK()`.
  - Deliverable C: Deterministic single-row tie-break pattern with `ROW_NUMBER()`.
  - Verification: File demonstrates ranking behavior differences across all three window functions.

- [x] D14 - LAG and LEAD (`queries/014_lag_lead.pgsql`)
  - Deliverable A: Previous-invoice lookup and gap calculation using `LAG()`.
  - Deliverable B: Next-invoice lookup and forward gap calculation using `LEAD()`.
  - Verification: Results are partitioned by customer and ordered by invoice chronology.

- [x] D15 - Running totals and rolling windows (`queries/015_running_totals.pgsql`)
  - Deliverable A: Running total of spend per customer using windowed `SUM()`.
  - Deliverable B: Rolling 7-day revenue window over invoice dates.
  - Deliverable C: `CROSS JOIN LATERAL` diagnostic query showing rows included in each rolling window.
  - Verification: File includes cumulative, rolling, and window-debug query variants.

- [x] D16 - Windowed percentile measures (`queries/016_window_percentiles.pgsql`)
  - Deliverable A: Customer spend percentile ranking using `PERCENT_RANK()` over aggregated customer totals.
  - Deliverable B: Track-price cumulative distribution using `CUME_DIST()`.
  - Verification: Query outputs identify top spenders by percentile and show cumulative position across track prices.

### E. CTEs, Recursive Queries, and Advanced Logic - Complete

- [x] E17 - Simple CTEs for staging/clarity (`queries/017_standalone_cte.pgsql`)
  - Deliverable A: `TrackArtist` staging CTE over `track`, `album`, and `artist`.
  - Deliverable B: Dependent `ArtistSales` CTE using line-level sales from `invoice_line`.
  - Deliverable C: Final artist-sales output ordered by total sales, with explanatory CTE notes retained in-file.
  - Verification: File contains a complete staged CTE workflow from join staging through final aggregation.

- [x] E18 - Recursive CTE: employee chain (`queries/018_recursive_cte.pgsql`)
  - Deliverable A: Recursive employee-chain traversal using `WITH RECURSIVE` and `reports_to`.
  - Deliverable B: Output fields `employee_id`, `reports_to`, `level`, and concatenated name/title path.
  - Deliverable C: Example start employee included in anchor member.
  - Verification: Recursive query returns stepwise hierarchy from selected employee to management chain.

- [x] E19 - Pivoting and crosstab fallback (`queries/019_pivot.pgsql`)
  - Deliverable A: Monthly revenue pivot for three months using `tablefunc.crosstab` (if extension available).
  - Deliverable B: Equivalent pivot using `SUM(...) FILTER (WHERE ...)` without extension.
  - Verification: both approaches return same month columns and same totals.

### F. Data Transformation and Cleaning - In Progress

- [x] F20 - Deduplication patterns (`queries/020_dedup.pgsql`)
  - Identify duplicate customers by (`first_name`, `last_name`, `email`) using `ROW_NUMBER()`.
  - Provide a safe delete plan that keeps the lowest `customer_id`.
  - Verification query: duplicate count is zero after cleanup in a test transaction.

- [x] F21 - Normalize composer into artist mapping (`migrations/021_normalize_composer.sql`, `queries/021_normalize_composer_checks.pgsql`)
  - Migration: create bridge table track_composer (track_id int references track(track_id), artist_id int references artist(artist_id), primary key (track_id, artist_id)).
  - Backfill using regexp_split_to_table (or string_to_array) to split track.composer into individual names (handle , and & as separators, and trim whitespace).
  - Insert distinct composer names into artist table using ON CONFLICT (name) DO NOTHING.
  - Populate track_composer by mapping each track_id to the corresponding artist_id.
  - Verification:
      - Show sample rows joining track → track_composer → artist (before/after structure comparison).
      - Count total rows in track_composer.
      - Show number of tracks with more than one composer.

- [ ] F22 - NULL handling and derived spend values (`queries/022_null_handling.pgsql`)
  - Build a query/view that computes customer spend with `COALESCE` when no invoices exist.
  - Optional path: add and maintain a physical `customer.total_spent` column.
  - Verification: customers without invoices resolve to 0, never NULL.

### G. Indexing and Performance Tuning (DBA) - Not Started

- [ ] G23 - Targeted indexes and benchmark (`migrations/023_create_indexes.sql`, `analysis/023_index_benchmark.md`)
  - Create indexes on `invoice(invoice_date)` and `invoice_line(track_id)`.
  - Capture `EXPLAIN (ANALYZE, BUFFERS)` before and after for one filter query.
  - Record runtime and buffer differences.

- [ ] G24 - Expression index (`migrations/024_expr_index.sql`, `queries/024_expr_index_check.pgsql`)
  - Create `LOWER(customer.email)` index.
  - Run a case-insensitive email lookup and show index usage in plan.

- [ ] G25 - Partial index (`migrations/025_partial_index.sql`, `queries/025_partial_index_check.pgsql`)
  - Create partial index on `invoice(invoice_date)` where `total > 100`.
  - Run a matching query and verify planner chooses the partial index.

- [ ] G26 - Functional date bucket index (`migrations/026_functional_index.sql`, `queries/026_functional_index_check.pgsql`)
  - Index `date_trunc('month', invoice_date)` expression.
  - Validate month-bucket reporting query and inspect plan impact.

### H. EXPLAIN, Profiling, and Comparisons - Not Started

- [ ] H27 - Before/after plan annotation (`analysis/027_explain_before.sql`, `analysis/027_explain_after.sql`, `analysis/027_explain_notes.md`)
  - Pick one slow join-heavy sales query.
  - Save before and after plans around one optimization.
  - Annotate node-level differences (join type, scan type, cost/time/buffers).

- [ ] H28 - Query stats exploration (`analysis/028_pg_stat_statements.md`, `queries/028_pg_stat_statements.pgsql`)
  - Pull top 10 queries by total time from `pg_stat_statements` (if available).
  - Propose one optimization candidate with rationale.

- [ ] H29 - Rewrite comparison (`queries/029_rewrite_for_performance.pgsql`)
  - Rewrite a correlated subquery into a join.
  - Rewrite an equivalent join back into a correlated form.
  - Compare plans and state which form is better in this dataset.

### I. Materialized Views, Caching, and Pre-Aggregation - Not Started

- [ ] I30 - Materialized view for top-selling tracks (`migrations/030_mv_top_tracks.sql`, `queries/030_query_mv.pgsql`)
  - Create materialized view with `track_id`, `total_sales` from `invoice_line`.
  - Add refresh command (and unique index if using concurrent refresh).
  - Query top 10 rows and document when this helps.

- [ ] I31 - Refresh strategy notes (`analysis/031_mv_refresh_strategy.md`)
  - Compare scheduled refresh vs event-driven refresh.
  - Add SQL snippets for full refresh and "recent data only" strategy.

### J. Transactions, Concurrency, and Safe Migrations - Not Started

- [ ] J32 - Safe multi-step column migration (`migrations/032_safe_column_add.sql`, `docs/032_safe_migration.md`)
  - Add nullable column, backfill in batches, enforce constraint, retire old column.
  - Include rollback notes for each stage.

- [ ] J33 - Isolation level demo (`tests/033_transactions_isolation.sql`)
  - Two-session scripts showing behavior under `READ COMMITTED` and `REPEATABLE READ`.
  - Capture expected anomalies/non-anomalies with notes.

- [ ] J34 - Advisory lock playbook (`docs/034_locking_guidelines.md`, `queries/034_advisory_lock_demo.pgsql`)
  - Provide a migration-coordination example using `pg_advisory_lock`.
  - Document safe usage rules and lock key conventions.

### K. Schema Design, Normalization, and Refactoring - Not Started

- [ ] K35 - ER diagram and tradeoffs (`docs/035_er_diagram.svg`, `docs/035_tradeoffs.md`)
  - Produce ER diagram for core Chinook entities.
  - Explain current normalization level and practical denormalization candidates.

- [ ] K36 - Partitioning design (`docs/036_partitioning_design.md`, optional `migrations/036_partition_example.sql`)
  - Design monthly/yearly partition strategy for `invoice`.
  - Provide executable DDL example and one routed insert example.

### L. Security, Roles, and Row-Level Policies - Not Started

- [ ] L37 - Roles and grants (`migrations/037_roles_and_grants.sql`)
  - Create reporting role with least-privilege read grants.
  - Verify role can read target tables and cannot mutate data.

- [ ] L38 - RLS example (`migrations/038_rls_example.sql`, `docs/038_rls_notes.md`)
  - Add tenant discriminator column to chosen table.
  - Enable RLS and create tenant-isolation policy.
  - Show session-context-based tenant filtering in action.

### M. Backup, Restore, and Migration Exercises - Not Started

- [ ] M39 - Backup and restore walkthrough (`scripts/039_backup_restore.sql`, `docs/039_backup_instructions.md`)
  - Document schema-only and full backup commands.
  - Document restore commands into a fresh database.
  - Add validation checks (row counts on core tables).

- [ ] M40 - CI migration and smoke tests (`.github/workflows/pr-check.yml`, `tests/040_ci_smoke_tests.sql`)
  - Ensure pipeline runs migrations and core smoke tests.
  - Add asserts for critical table existence and non-empty baselines.

### N. Monitoring, Observability, and Health Checks - Not Started

- [ ] N41 - Health check query pack (`scripts/041_health_checks.sql`, `docs/041_monitoring.md`)
  - Active connections and long-running queries.
  - Table stats snapshot for core tables.
  - Include threshold guidance for warning conditions.

- [ ] N42 - Scheduled DB ping (`.github/workflows/042_db_ping.yml`)
  - Scheduled workflow executes `SELECT 1` and one lightweight domain query.
  - Fail workflow on timeout/error and document expected runtime.

### O. Extensions and Advanced Postgres Features - Not Started

- [ ] O43 - Full-text search demo (`migrations/043_fulltext.sql`, `queries/043_fulltext_queries.pgsql`)
  - Add `tsvector` index strategy for searchable track text.
  - Provide ranked search examples with `@@` and `ts_rank`.

- [ ] O44 - JSONB usage demo (`migrations/044_jsonb_example.sql`, `queries/044_jsonb_queries.pgsql`)
  - Add JSONB metadata field and sample payloads.
  - Query nested keys and path expressions with index-aware patterns.

- [ ] O45 - PostGIS concept note (`docs/045_postgis_notes.md`)
  - Describe how geospatial features could extend Chinook use cases.
  - Include one illustrative spatial query idea.

### P. Stored Procedures, Triggers, and Auditing - Not Started

- [ ] P46 - Invoice audit trigger (`migrations/046_audit_trigger.sql`, `queries/046_audit_queries.pgsql`)
  - Create audit table and trigger function for INSERT/UPDATE/DELETE.
  - Store old/new row payloads as JSONB.
  - Add retrieval query for one invoice history timeline.

- [ ] P47 - Stored procedure for invoice creation (`migrations/047_invoice_proc.sql`, `tests/047_invoice_proc_test.sql`)
  - Function inserts invoice plus invoice lines atomically from JSON input.
  - Validate totals and line counts in test script.

### Q. Concurrency, Load, and Capacity Planning - Not Started

- [ ] Q48 - Concurrent workload simulation (`scripts/048_concurrency_test.sql`, `analysis/048_load_results.md`)
  - Simulate concurrent reads/writes against invoice-related tables.
  - Capture lock waits, contention, and deadlock outcomes if any.
  - Summarize mitigation steps (indexing, shorter transactions, batching).

- [ ] Q49 - Capacity planning baseline (`docs/049_capacity_planning.md`, `queries/049_storage_growth.pgsql`)
  - Measure current table/index sizes for core entities.
  - Estimate growth from observed insert rates and retention assumptions.

### R. Data Lineage, Documentation, and Tests - Not Started

- [ ] R50 - Report lineage note (`docs/050_lineage_example.md`)
  - Pick one report query and trace source tables and transforms.
  - Include a simple lineage diagram.

- [ ] R51 - Critical query tests (`tests/051_query_tests.sql`)
  - Add at least two assertions for expected row shape/count/value ranges.

- [ ] R52 - Query catalog (`queries/README.md`)
  - One-line purpose, tags, and complexity per query file.

- [ ] R53 - CI assertions for key objects (`tests/053_ci_assertions.sql`, `.github/workflows/pr-check.yml`)
  - Assert baseline data presence and required objects after migrations.

### X. Optional Extras and Polish - Not Started

- [ ] X1 - Add screenshots or short demo videos for three highlight tasks (`artifacts/videos/`).
- [ ] X2 - Add a quickstart page linking runnable Supabase snippets.
- [ ] X3 - Add SQL idioms cheat sheet (`docs/CHEATSHEET.md`).