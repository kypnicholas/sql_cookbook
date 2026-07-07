-- TASK FORMAT
-- Task ID: G24
-- Title: Expression index for date range
-- Goal: Create an expression index on invoice(invoice_date::date) to improve query performance for date range filters.
-- Deliverable: Create the index and capture EXPLAIN (ANALYZE, BUFFERS) before and after for one filter query.
-- Verification: Record runtime and buffer differences to demonstrate performance improvement.
-- -----------------------------------------------------------------------------

/*
Expression index definition:
An expression index is an index that is created based on the result of an expression or function applied to one or more columns. 
It allows for indexing computed values, enabling efficient query performance for queries that filter or sort based on those computed values. 
In this case, we are creating an expression index on the invoice_date column cast to date, which can improve performance for queries 
that filter on the date portion of the timestamp.
*/

-- Baseline for invoice(invoice_date::date) index.
-- Invoice_date filter and AGGREGATE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT SUM(total) as total_invoice_amount FROM invoice
WHERE invoice_date::date >= '2021-01-01'::date
  AND invoice_date::date <  '2022-01-01'::date;


