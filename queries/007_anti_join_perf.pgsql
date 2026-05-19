-- TASK FORMAT
-- Task ID: B7-SUP
-- Title: Anti-join performance comparison
-- Goal: Compare execution plans of LEFT JOIN IS NULL and NOT EXISTS anti-join forms.
-- Deliverables: EXPLAIN ANALYZE runs and planning notes.
-- Verification: Plan nodes and timings are captured for both query forms.
-- EXPLAIN/ANALYZE comparisons: anti-join (LEFT JOIN/IS NULL) vs NOT EXISTS.
-- File: queries/007_anti_join_explain.pgsql.
-- WARNING: Running the EXPLAINs with ANALYZE will execute the queries.

-- 1) Refresh planner statistics (recommended before benchmarking)
VACUUM ANALYZE public.track;
VACUUM ANALYZE public.invoice_line;

-- 2) Anti-join (LEFT JOIN / IS NULL)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT t.*
FROM public.track t
LEFT JOIN public.invoice_line il ON t.track_id = il.track_id
WHERE il.track_id IS NULL;

-- 3) NOT EXISTS (correlated subquery)
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT t.*
FROM public.track t
WHERE NOT EXISTS (
  SELECT 1 FROM public.invoice_line il WHERE il.track_id = t.track_id
);

-- Notes:
-- - Run each EXPLAIN multiple times to compare cold vs warm cache behavior.
-- - Use the JSON output to compare node types, actual times, and buffer usage.
-- - Consider using pg_stat_statements for aggregated production metrics.

