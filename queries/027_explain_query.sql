-- TASK FORMAT
-- Task ID: H27
-- Title: Before/after plan annotation
-- Goal: Pick one slow join-heavy sales query and capture EXPLAIN (ANALYZE, BUFFERS) before and after any performance tuning changes.
-- Deliverable: Capture EXPLAIN (ANALYZE, BUFFERS) before and after for a slow join-heavy sales query, and annotate the plan to explain the differences.
-- Verification: Record runtime and buffer differences to demonstrate performance improvement. 
------------------------------------------------------------------------------

/*
Purpose: 
Deep, node‑by‑node EXPLAIN annotation — explain why the planner changed, which node costs/times changed, and the root cause 
(e.g., index changed scan type, reduced heap blocks, removed sort/hash build). 

High-level steps:
1. Pick one slow, join‑heavy sales query. [Save to queries/027_explain_query.sql]
2. Capture a clean baseline EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON + readable text). [Save to analysis/027_explain_before.json]
3. Pick one targeted optimization (index, rewrite, materialized view). Implement it. 
  3.1. First attempted optimization: create index on invoice_date column of invoice table. [Save to migration/027_create_index.sql]. Performance DID NOT IMPROVE. 
  3.2. Second attempted optimization: re-write query to remove unnecessary joins and reduce aggregation. [Save to queries/027_explain_query.sql]. 
4. Re-run VACUUM/ANALYZE, capture after EXPLAIN. [Save to analysis/027_explain_after.json]
5. Produce node‑level annotated comparison. [Save to analysis/027_explain_notes.md] (table + plain takeaways).

*/ 


-- Standardized query for testing EXPLAIN (ANALYZE, BUFFERS) before and after performance tuning changes.

-- 2.1.) Ensure you are using the same session settings for before/after
SET jit = off;                  -- Disable JIT for consistent timings/plan structure across environments
SET work_mem = '64MB';          -- Keep memory stable for hash/agg/sort behaviors

-- Optional but can help stabilize plan choices
SET enable_seqscan = on;         -- keep default-ish; don't constrain unless needed
SET enable_hashjoin = on;
SET enable_mergejoin = on;
SET enable_nestloop = on;
SET enable_sort = on;
SET enable_hashagg = on;


-- 2.2.) Baseline run: SELECT TOP 10 artists by revenue, grouped by genre, for all time.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)     -- In supabase, use EXPLAIN (ANALYZE, BUFFERS, VERBOSE, FORMAT JSON) to get a JSON output of the plan.
SELECT
  ar.name AS artist_name,
  g.name  AS genre_name,
  SUM(il.unit_price * il.quantity) AS revenue,
  COUNT(*) AS line_items
FROM public.invoice_line il
JOIN public.invoice i
  ON i.invoice_id = il.invoice_id
JOIN public.customer c
  ON c.customer_id = i.customer_id
JOIN public.track t
  ON t.track_id = il.track_id
JOIN public.album a
  ON a.album_id = t.album_id
JOIN public.artist ar
  ON ar.artist_id = a.artist_id
LEFT JOIN public.genre g
  ON g.genre_id = t.genre_id
WHERE i.invoice_date >= (NOW() - INTERVAL '100 years')
GROUP BY ar.name, g.name
ORDER BY revenue DESC
LIMIT 10;

-- 2.3.) Record settings we might need to write up the report
SHOW jit;
SHOW work_mem;
SHOW enable_hashjoin;
SHOW enable_nestloop;
SHOW enable_mergejoin;
SHOW enable_sort;


-- 3.2. ) Re-written query to remove unnecessary joins and reduce aggregation.
-- Removed customer join (not used in SELECT or WHERE) to reduce join complexity.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)     
SELECT
  ar.name AS artist_name,
  g.name  AS genre_name,
  SUM(il.unit_price * il.quantity) AS revenue,
  COUNT(*) AS line_items
FROM public.invoice_line il
JOIN public.invoice i
  ON i.invoice_id = il.invoice_id
JOIN public.track t
  ON t.track_id = il.track_id
JOIN public.album a
  ON a.album_id = t.album_id
JOIN public.artist ar
  ON ar.artist_id = a.artist_id
LEFT JOIN public.genre g
  ON g.genre_id = t.genre_id
WHERE i.invoice_date >= (NOW() - INTERVAL '100 years')
GROUP BY ar.name, g.name
ORDER BY revenue DESC
LIMIT 10;