
-- EXPLAINING THE OUTPUT FROM THE PERFORMANCE QUERIES

OUTPUT FROM RUNNING: 

-- 2) Anti-join (LEFT JOIN / IS NULL)
```sql
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT t.*
FROM public.track t
LEFT JOIN public.invoice_line il ON t.track_id = il.track_id
WHERE il.track_id IS NULL;
```


```text
Hash Anti Join  (cost=65.40..174.53 rows=1519 width=70) (actual time=0.684..1.716 rows=1519 loops=1)
  Output: t.track_id, t.name, t.album_id, t.media_type_id, t.genre_id, t.composer, t.milliseconds, t.bytes, t.unit_price
  Hash Cond: (t.track_id = il.track_id)
  Buffers: shared hit=60
  ->  Seq Scan on public.track t  (cost=0.00..80.03 rows=3503 width=70) (actual time=0.016..0.331 rows=3503 loops=1)
    Output: t.track_id, t.name, t.album_id, t.media_type_id, t.genre_id, t.composer, t.milliseconds, t.bytes, t.unit_price
    Buffers: shared hit=45
  ->  Hash  (cost=37.40..37.40 rows=2240 width=4) (actual time=0.646..0.647 rows=2240 loops=1)
    Output: il.track_id
    Buckets: 4096  Batches: 1  Memory Usage: 111kB
    Buffers: shared hit=15
    ->  Seq Scan on public.invoice_line il  (cost=0.00..37.40 rows=2240 width=4) (actual time=0.011..0.265 rows=2240 loops=1)
      Output: il.track_id
      Buffers: shared hit=15
Query Identifier: -5238514743289128790
Planning:
  Buffers: shared hit=291
Planning Time: 0.864 ms
Execution Time: 1.821 ms
```


**Quick interpretation**

- **Plan type:** Hash Anti Join — returns rows from `track` that have no matching `invoice_line`.  
- **How it ran:** Planner did a sequential scan of `track` (3503 rows) and built a hash from `invoice_line` (2240 rows), then probed the hash with each `track` row using `t.track_id = il.track_id`.  
- **Resources / perf:** small buffer usage (shared hit=60), hash memory ~111kB, execution time ~1.82 ms — indicates the work was in-memory and very fast.  
- **Why planner chose this:** the build side (`invoice_line`) is smaller and a hash-based anti-join was cheapest given current stats; also no need for an index if hash is cheap.  
- **Takeaway:** this is an efficient plan for current data sizes — no obvious problem.  
- **If you want to optimize further:**  
  - Ensure stats are up-to-date (`VACUUM ANALYZE`) — you already ran that.  
  - Add an index on `public.invoice_line(track_id)` if you frequently run this anti-join; that can enable nested-loop/index plans for very skewed data or different workloads.  
  - Compare with the `NOT EXISTS` plan (run the other EXPLAIN you added) and compare `actual time`, `Buffers`, and node types; paste that output and I’ll interpret differences.