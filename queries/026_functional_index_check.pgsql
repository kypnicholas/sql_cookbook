-- TASK FORMAT
-- Task ID: G26
-- Title: Functional index for invoice date truncation
-- Goal: Create a functional index on invoice(invoice_date) using the date_trunc function to optimize queries that group invoices by month.
-- Deliverable: Create the functional index and capture EXPLAIN (ANALYZE, BUFFERS) before and after for a query that groups invoices by month.
-- Verification: Record runtime and buffer differences to demonstrate performance improvement.
-- -----------------------------------------------------------------------------

/*
Functional index definition:
A functional index is created on the result of a function applied to one or more columns in a table.
In this case, we are creating a functional index on the invoice_date column of the invoice table,
using the date_trunc function to group invoices by month. This allows for more efficient query performance when grouping invoices by month, as the index will store the truncated date values.
*/

-- Baseline for invoice(invoice_date) functional index.
-- Invoice_date filter and AGGREGATE with date_trunc for monthly grouping
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT date_trunc('month', invoice_date) AS month,
       COUNT(*) AS invoice_count,
       SUM(total) AS total_amount
FROM invoice
GROUP BY month
ORDER BY month;



/*
-- BEFORE -- 

QUERY PLAN
Sort  (cost=34.54..35.42 rows=354 width=48) (actual time=6.533..6.538 rows=60 loops=1)
"  Output: (date_trunc('month'::text, invoice_date)), (count(*)), (sum(total))"
"  Sort Key: (date_trunc('month'::text, invoice.invoice_date))"
"  Sort Method: quicksort  Memory: 27kB"
"  Buffers: shared hit=9"
"  ->  HashAggregate  (cost=14.24..19.55 rows=354 width=48) (actual time=6.467..6.495 rows=60 loops=1)"
"        Output: (date_trunc('month'::text, invoice_date)), count(*), sum(total)"
"        Group Key: date_trunc('month'::text, invoice.invoice_date)"
"        Batches: 1  Memory Usage: 61kB"
"        Buffers: shared hit=6"
"        ->  Seq Scan on public.invoice  (cost=0.00..11.15 rows=412 width=14) (actual time=1.257..6.287 rows=412 loops=1)"
"              Output: date_trunc('month'::text, invoice_date), total"
"              Buffers: shared hit=6"
Query Identifier: -6928962261830715291
Planning:
"  Buffers: shared hit=129"
Planning Time: 4.341 ms
Execution Time: 6.722 ms


-- AFTER --

QUERY PLAN
GroupAggregate  (cost=0.15..24.56 rows=354 width=48) (actual time=0.056..0.321 rows=60 loops=1)
"  Output: (date_trunc('month'::text, invoice_date)), count(*), sum(total)"
"  Group Key: date_trunc('month'::text, invoice.invoice_date)"
"  Buffers: shared hit=6 read=1"
"  ->  Index Scan using idx_invoice_date_trunc_month on public.invoice  (cost=0.15..16.16 rows=412 width=14) (actual time=0.037..0.210 rows=412 loops=1)"
"        Output: date_trunc('month'::text, invoice_date), total"
"        Buffers: shared hit=6 read=1"
Query Identifier: -6928962261830715291
Planning:
"  Buffers: shared hit=147 read=1"
Planning Time: 1.948 ms
Execution Time: 0.437 ms

*/ 