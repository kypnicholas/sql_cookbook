

-- CTE Definition
-- A Common Table Expression (CTE) is a temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 
-- It is defined using the WITH clause and can be used to simplify complex queries, improve readability, and enable recursive queries.

WITH recent_invoices AS (
    SELECT
        customer_id,
        invoice_id,
        invoice_date,
        total
    FROM invoice
    WHERE invoice_date >= CURRENT_DATE - INTERVAL '300 days'
)   
SELECT
    customer_id,
    invoice_id,
    invoice_date,
    total
FROM recent_invoices
ORDER BY invoice_date DESC;