-- TASK FORMAT
-- Task ID: G23
-- Title: Targeted indexes and benchmark
-- Goal: Create indexes on invoice(invoice_date) and invoice_line(track_id) to improve query performance.
-- Deliverable: Create the indexes and capture EXPLAIN (ANALYZE, BUFFERS) before and after for one filter query.
-- Verification: Record runtime and buffer differences to demonstrate performance improvement.
-- -----------------------------------------------------------------------------

-- Find a sample track_id to test index selectively
SELECT track_id, count(*) AS invoice_count from invoice_line
GROUP BY track_id
ORDER BY invoice_count DESC
LIMIT 1;

-- Query A: Baseline for invoice(invoice_date) index. 
-- Invoice_date filter and AGGREGATE

EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT SUM(total) as total_invoice_amount FROM invoice
WHERE invoice_date >= '2010-01-01' AND invoice_date < '2011-01-01';




