-- TASK FORMAT
-- Task ID: G24
-- Title: Expression index for date range
-- Goal: Create an expression index on invoice(invoice_date::date) to improve query performance for date range filters.
-- Deliverable: Create the index and capture EXPLAIN (ANALYZE, BUFFERS) before and after for one filter query.
-- Verification: Record runtime and buffer differences to demonstrate performance improvement.
-- -----------------------------------------------------------------------------

-- Baseline for invoice(invoice_date::date) index.
-- Invoice_date filter and AGGREGATE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT SUM(total) as total_invoice_amount FROM invoice
WHERE invoice_date::date >= '2021-01-01'::date
  AND invoice_date::date <  '2022-01-01'::date;


