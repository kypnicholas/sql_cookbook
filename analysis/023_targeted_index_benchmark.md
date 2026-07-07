# G23 Benchmark Notes

## Goal
Measure whether the targeted indexes improve the benchmark queries in `queries/023_targeted_index_benchmark_check.pgsql`.

## In order of execution
1. Found a representative `track_id` from `invoice_line`.
   ```sql
   SELECT track_id, count(*) AS invoice_count
   FROM invoice_line
   GROUP BY track_id
   ORDER BY invoice_count DESC
   LIMIT 1;
   ```
   Result: `track_id = 118312`.

2. Ran Query A before applying the new date index. This is the baseline for the `invoice_date` filter.

3. Ran Query B and Query C after the index work to confirm the `track_id` index path was active.

4. Re-ran Query A after applying an index on `invoice_date` so I could compare the same query before and after.

## Query A before index
This was the baseline plan for the date-range aggregate on `invoice`.

Que

```text
Aggregate  (cost=14.25..14.26 rows=1 width=32) (actual time=0.117..0.117 rows=1 loops=1)
  Output: sum(total)
  Buffers: shared hit=6
  ->  Seq Scan on public.invoice  (cost=0.00..14.24 rows=2 width=6) (actual time=0.012..0.092 rows=83 loops=1)
        Output: invoice_id, customer_id, invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal_code, total
        Filter: (((invoice.invoice_date)::date >= '2021-01-01'::date) AND ((invoice.invoice_date)::date < '2022-01-01'::date))
        Rows Removed by Filter: 329
        Buffers: shared hit=6
Query Identifier: -8955638251621143402
Planning:
  Buffers: shared hit=38
Planning Time: 0.159 ms

```sql
-- Query A (baseline)
SELECT SUM(total) AS total_invoice_amount
FROM invoice
WHERE invoice_date::date >= '2021-01-01'::date
  AND invoice_date::date <  '2022-01-01'::date;
```
Execution Time: 0.154 ms
```

### Query A summary

| Aspect | Before index | Meaning |
|---|---|---|
| Scan type | `Seq Scan on public.invoice` | PostgreSQL checked every row in the table. |
| Rows matched | `83` | These are the invoices in the requested date range. |
| Rows filtered out | `329` | Most rows did not match the date range. |
| Buffers | `shared hit=6` | The table fit in a small number of in-memory pages. |
| Planning time | `0.159 ms` | Time spent choosing the plan. |
| Execution time | `0.154 ms` | Time spent actually running the query. |

### What this means
- This is the clean baseline because it does not use the date index.
- The planner had no index-assisted path for the `invoice_date::date` filter, so it read the table row by row.
- The result is correct, but the access path is not optimal for larger datasets.

## Query A after index
This is the same query after creating the date expression index.

```text
Aggregate  (cost=3.53..3.54 rows=1 width=32) (actual time=0.098..0.099 rows=1 loops=1)
  Output: sum(total)
  Buffers: shared hit=2 read=2
  ->  Bitmap Heap Scan on public.invoice  (cost=1.39..3.52 rows=2 width=6) (actual time=0.046..0.058 rows=83 loops=1)
        Output: invoice_id, customer_id, invoice_date, billing_address, billing_city, billing_state, billing_country, billing_postal_code, total
        Recheck Cond: (((invoice.invoice_date)::date >= '2021-01-01'::date) AND ((invoice.invoice_date)::date < '2022-01-01'::date))
        Heap Blocks: exact=2
        Buffers: shared hit=2 read=2
        ->  Bitmap Index Scan on idx_invoice_invoice_date_date  (cost=0.00..1.39 rows=2 width=0) (actual time=0.025..0.025 rows=83 loops=1)
              Index Cond: (((invoice.invoice_date)::date >= '2021-01-01'::date) AND ((invoice.invoice_date)::date < '2022-01-01'::date))
              Buffers: shared read=2
Query Identifier: -8955638251621143402
Planning:
  Buffers: shared hit=63 read=1
Planning Time: 0.271 ms
Execution Time: 0.129 ms
```

```sql
-- Query A (after index)
SELECT SUM(total) AS total_invoice_amount
FROM invoice
WHERE invoice_date::date >= '2021-01-01'::date
  AND invoice_date::date <  '2022-01-01'::date;
```

### Query A summary

| Aspect | After index | Meaning |
|---|---|---|
| Scan type | `Bitmap Heap Scan on public.invoice` with `Bitmap Index Scan on idx_invoice_invoice_date_date` | PostgreSQL used the index to find matching rows first, then fetched only the needed heap pages. |
| Rows matched | `83` | The query result is unchanged. |
| Heap blocks | `exact=2` | Only two table pages were needed after the index lookup. |
| Buffers | `shared hit=2 read=2` | Some pages were already cached; two had to be read. |
| Planning time | `0.271 ms` | Slightly higher because the planner had an index path to consider. |
| Execution time | `0.129 ms` | Slightly faster than the baseline. |

### What this means
- This is the improved plan because the date expression index is being used.
- The query still returns the same 83 rows, so only the access path changed.
- The improvement is small because the table is tiny, but the plan shape is better and will scale better as the table grows.
- A Bitmap Heap Scan is a normal and expected choice when an index returns a moderate number of matching rows.

## Query B after index
This confirms the `track_id` lookup is using the intended index.

```text
Limit  (cost=0.28..2.50 rows=1 width=21) (actual time=0.026..0.028 rows=2 loops=1)
  Output: invoice_line_id, invoice_id, track_id, unit_price, quantity
  Buffers: shared hit=2 read=2
  ->  Index Scan using idx_invoice_line_track_id on public.invoice_line  (cost=0.28..2.50 rows=1 width=21) (actual time=0.025..0.026 rows=2 loops=1)
        Output: invoice_line_id, invoice_id, track_id, unit_price, quantity
        Index Cond: (invoice_line.track_id = 1831)
        Buffers: shared hit=2 read=2
Query Identifier: -359903261482482402
Planning:
  Buffers: shared hit=12
Planning Time: 0.068 ms
Execution Time: 0.040 ms
```

```sql
-- Query B
SELECT * FROM invoice_line
WHERE track_id = 1831
LIMIT 100;
```

### Query B summary

| Aspect | After index | Meaning |
|---|---|---|
| Scan type | `Index Scan using idx_invoice_line_track_id` | The lookup jumps directly to matching rows in `invoice_line`. |
| Rows returned | `2` | Only two lines matched the chosen `track_id`. |
| Buffers | `shared hit=2 read=2` | The index and a small amount of table data were accessed. |
| Planning time | `0.068 ms` | Very small planning overhead. |
| Execution time | `0.040 ms` | Fast point lookup. |

### What this means
- This query is a clean confirmation that the `track_id` index is working.
- It is not a before/after comparison in the same sense as Query A because the index was already active by the time this run was captured.

## Query C after index
This confirms the join path also uses both indexes.

```text
Limit  (cost=6.05..6.06 rows=1 width=25) (actual time=0.075..0.077 rows=1 loops=1)
  Output: i.invoice_id, i.invoice_date, il.track_id, il.unit_price, il.quantity
  Buffers: shared hit=14
  ->  Sort  (cost=6.05..6.06 rows=1 width=25) (actual time=0.075..0.075 rows=1 loops=1)
        Output: i.invoice_id, i.invoice_date, il.track_id, il.unit_price, il.quantity
        Sort Key: i.invoice_date DESC
        Sort Method: quicksort  Memory: 25kB
        Buffers: shared hit=14
        ->  Nested Loop  (cost=1.67..6.04 rows=1 width=25) (actual time=0.035..0.061 rows=1 loops=1)
              Output: i.invoice_id, i.invoice_date, il.track_id, il.unit_price, il.quantity
              Inner Unique: true
              Join Filter: (i.invoice_id = il.invoice_id)
              Rows Removed by Join Filter: 136
              Buffers: shared hit=11
              ->  Index Scan using idx_invoice_line_track_id on public.invoice_line il  (cost=0.28..2.50 rows=1 width=17) (actual time=0.004..0.005 rows=2 loops=1)
                    Output: il.invoice_line_id, il.invoice_id, il.track_id, il.unit_price, il.quantity
                    Index Cond: (il.track_id = 1831)
                    Buffers: shared hit=4
              ->  Bitmap Heap Scan on public.invoice i  (cost=1.39..3.52 rows=2 width=12) (actual time=0.014..0.019 rows=68 loops=2)
                    Output: i.invoice_id, i.customer_id, i.invoice_date, i.billing_address, i.billing_city, i.billing_state, i.billing_country, i.billing_postal_code, i.total
                    Recheck Cond: (((i.invoice_date)::date >= '2021-01-01'::date) AND ((i.invoice_date)::date < '2022-01-01'::date))
                    Heap Blocks: exact=3
                    Buffers: shared hit=7
                    ->  Bitmap Index Scan on idx_invoice_invoice_date_date  (cost=0.00..1.39 rows=2 width=0) (actual time=0.007..0.007 rows=83 loops=2)
                          Index Cond: (((i.invoice_date)::date >= '2021-01-01'::date) AND ((i.invoice_date)::date < '2022-01-01'::date))
                          Buffers: shared hit=4
Query Identifier: -8054397524101275721
Planning:
  Buffers: shared hit=74
Planning Time: 1.742 ms
Execution Time: 0.104 ms
```

```sql
-- Query C
SELECT i.invoice_id, i.invoice_date, il.track_id, il.unit_price, il.quantity
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE invoice_date::date >= '2021-01-01'::date
  AND invoice_date::date <  '2022-01-01'::date
  AND il.track_id = 1831
ORDER BY i.invoice_date DESC
LIMIT 100;
```

### Query C summary

| Aspect | After index | Meaning |
|---|---|---|
| Join shape | `Nested Loop` | PostgreSQL joined the small `invoice_line` result set to `invoice`. |
| Lookup on `invoice_line` | `Index Scan using idx_invoice_line_track_id` | The track filter was satisfied by the index. |
| Lookup on `invoice` | `Bitmap Heap Scan` via `idx_invoice_invoice_date_date` | The date filter used the new expression index. |
| Sort | `Sort Key: i.invoice_date DESC` | PostgreSQL sorted the final small result set for the `ORDER BY`. |
| Rows returned | `1` | Only one joined row survived both filters. |
| Execution time | `0.104 ms` | Slightly slower than Query A because it has to join and sort. |

### What this means
- Query C proves both indexes can participate in the same plan.
- It is useful as supporting evidence, but it is not the best benchmark for performance gain because the planner still has to perform join work and a final sort.
- The `Rows Removed by Join Filter: 136` line shows that the join had extra work to do even though the output is tiny.

## Cross-query comparison

| Query | Best plan feature | Main takeaway |
|---|---|---|
| A | Date expression index on `invoice(invoice_date::date)` | This is the real before/after benchmark and shows the cleanest improvement. |
| B | Index scan on `invoice_line(track_id)` | Confirms the track index is active and efficient for point lookups. |
| C | Nested loop + both indexes | Good proof that both indexes can work together, but not the strongest performance win case. |

