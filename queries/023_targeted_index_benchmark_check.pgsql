-- TASK FORMAT
-- Task ID: G23
-- Title: Targeted indexes and benchmark
-- Goal: Create indexes on invoice(invoice_date) and invoice_line(track_id) to improve query performance.
-- Deliverable: Create the indexes and capture EXPLAIN (ANALYZE, BUFFERS) before and after for one filter query.
-- Verification: Record runtime and buffer differences to demonstrate performance improvement.
-- -----------------------------------------------------------------------------

/*
Targeted index defintion: 
Targeted index is the standard column index and is used to improve query performance for specific columns 
that are frequently used in WHERE clauses or JOIN conditions. 
*/

-- Find a sample track_id to test index selectively
SELECT track_id, count(*) AS invoice_count from invoice_line
GROUP BY track_id
ORDER BY invoice_count DESC
LIMIT 1;

-- Query A: Baseline for invoice(invoice_date) index. 
-- Invoice_date filter and AGGREGATE

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT SUM(total) as total_invoice_amount FROM invoice
WHERE invoice_date::date >= '2021-01-01'::date
  AND invoice_date::date <  '2022-01-01'::date;


-- Query B: Point lookup on invoice_line(track_id) index.
-- Find all invoice lines for a specific track_id to demonstrate the effect of the index on point lookups.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT * FROM invoice_line
WHERE track_id = 1831
LIMIT 100;

-- QUERY C: Join query to demonstrate the effect of indexes on join performance.
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT i.invoice_id, i.invoice_date, il.track_id, il.unit_price, il.quantity
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE invoice_date::date >= '2021-01-01'::date
  AND invoice_date::date <  '2022-01-01'::date
  AND il.track_id = 1831
ORDER BY i.invoice_date DESC
LIMIT 100;