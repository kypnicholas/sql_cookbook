# G23 Benchmark Notes

## Goal
Measure whether the two targeted indexes improve the benchmark queries in `queries/023_index_benchmark_check.pgsql`.

## Exact order used
1. Picked a representative `track_id` from `invoice_line`:
   ```sql
   SELECT track_id, count(*) AS invoice_count
   FROM invoice_line
   GROUP BY track_id
   ORDER BY invoice_count DESC
   LIMIT 1;
   ```
   Result: `track_id = 118312`.

2. Ran Query A as the baseline date-range aggregate on `invoice`.
   ```sql
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
   SELECT SUM(total) AS total_invoice_amount
   FROM invoice
   WHERE invoice_date::date >= '2021-01-01'::date
     AND invoice_date::date < '2022-01-01'::date;
   ```
   Result:
   - `Seq Scan on public.invoice`
   - `83` rows matched, `329` rows removed by filter
   - `Execution Time: 0.154 ms`
   - `shared hit=6`

3. Ran Query B to confirm the `invoice_line(track_id)` index path.
   ```sql
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
   SELECT *
   FROM invoice_line
   WHERE track_id = 1831
   LIMIT 100;
   ```
   Result:
   - `Index Scan using invoice_line_track_id_idx`
   - `2` rows returned
   - `Execution Time: 0.023 ms`
   - `shared hit=4`

4. Ran Query C to confirm the join path also uses the `track_id` index.
   ```sql
   EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
   SELECT i.invoice_id, i.invoice_date, il.track_id, il.unit_price, il.quantity
   FROM invoice i
   JOIN invoice_line il ON i.invoice_id = il.invoice_id
   WHERE invoice_date::date >= '2021-01-01'::date
     AND invoice_date::date < '2022-01-01'::date
     AND il.track_id = 1831
   ORDER BY i.invoice_date DESC
   LIMIT 100;
   ```
   Result:
   - `Index Scan using invoice_line_track_id_idx`
   - `Index Scan using invoice_pkey`
   - `1` row returned
   - `Execution Time: 0.046 ms`

## What this means
- Query A is the useful baseline for the future `invoice(invoice_date)` comparison.
- Query B and Query C already show the effect of the `invoice_line(track_id)` index, so they are not a clean before-state benchmark for that table.
- The current date range is valid because it returns rows, so you can now compare the same Query A before and after adding `invoice(invoice_date)`.

## Next run order after the index is applied
1. Run the migration in `migrations/023_create_indexes.sql`.
2. Re-run Query A exactly as written above.
3. Compare the new plan to the baseline:
   - scan type
   - execution time
   - rows matched vs rows removed by filter
   - shared buffer hits
4. Keep Query B and Query C as supporting evidence that the `track_id` index is active.

## Notes
- The current `invoice_line_track_id_idx` is already being used, so do not label those plans as baseline.
- If you want a true before/after for `invoice_line(track_id)`, you would need to drop that index, capture a baseline, then recreate it. For this task, that is unnecessary because G23 only needs one filter query comparison.