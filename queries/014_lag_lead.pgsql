-- TASK FORMAT
-- Task ID: D14
-- Title: LAG and LEAD
-- Goal: Compute inter-invoice time gaps using previous/next row access.
-- Deliverables: days since prior invoice and days until next invoice per customer.
-- Verification: Nulls appear at partition edges and intervals compute correctly.

-- For each customer, compute days between consecutive invoices: invoice_date - LAG(invoice_date).

-- LAG definition.
-- The LAG() window function allows you to access data from a previous row in the same result set without the need for a self-join.
-- It is often used to compare values between rows or to calculate differences over time.

SELECT
    customer_id,
    invoice_id,
    invoice_date,
    LAG(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS previous_invoice_date,
    EXTRACT(DAY FROM (invoice_date - LAG(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date))) AS days_between_invoices
FROM invoice
ORDER BY customer_id, invoice_date;



-- Use LEAD to peek next invoice per customer.

-- LEAD definition.
-- The LEAD() window function allows you to access data from a subsequent row in the same result set without the need for a self-join.
-- It is often used to compare values between rows or to calculate differences over time.


SELECT
    customer_id,
    invoice_id,
    invoice_date,
    LEAD(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS next_invoice_date,
    EXTRACT(DAY FROM (LEAD(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date) - invoice_date)) AS days_until_next_invoice
FROM invoice
ORDER BY customer_id, invoice_date;

