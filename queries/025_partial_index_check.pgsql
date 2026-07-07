-- TASK FORMAT
-- Task ID: G25
-- Title: Partial index for invoice total
-- Goal: Create a partial index on invoice(invoice_date) where total > 100 to optimize queries that filter for invoices with a total greater than 100.
-- Deliverable: Create the partial index and capture EXPLAIN (ANALYZE, BUFFERS) before and after for a query filtering on total > 100.
-- Verification: Record runtime and buffer differences to demonstrate performance improvement.
-- -----------------------------------------------------------------------------

/*
Partial index definition:
A partial index is an index that is created on a subset of rows in a table, based on a specified condition.
In this case, we are creating a partial index on the invoice_date column of the invoice table, 
but only for rows where the total is greater than 100. This allows for more efficient query performance 
when filtering for invoices with a total greater than 100, as the index will only include relevant rows.
*/

-- Baseline for invoice(invoice_date) partial index.
-- Invoice_date filter and AGGREGATE with total > 100
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT SUM(total) as total_invoice_amount FROM invoice
WHERE invoice_date::date >= '2021-01-01'::date
  AND invoice_date::date <  '2022-01-01'::date
  AND total > 100;
  