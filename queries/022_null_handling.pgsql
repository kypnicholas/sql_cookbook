-- TASK FORMAT
-- Task ID: F22
-- Title: Null handling and COALESCE usage
-- Goal: Demonstrate how to handle NULL values in queries using COALESCE and other techniques
-- Deliverable: Query/view that computes customer spend with COALESCE when no invoices exist
-- Verification: Show sample rows with NULL invoice totals replaced by 0 using COALESCE. Never display NULL in the final output for total spend.
-- -----------------------------------------------------------------------------

-- Get list of customers with no invoices (i.e., customers with NULL invoice totals). This is a common scenario where COALESCE can be used to handle NULL values.
SELECT c.customer_id
FROM customer c
LEFT JOIN invoice i
    ON i.customer_id = c.customer_id
WHERE i.customer_id IS NULL;

-- The original dataset does not have any customers with no invoices, so we will create a fake customer and get a list of customers with no invoices, including the fake customer. 
WITH fake_customer AS (
    SELECT 9999 AS customer_id, 'Test' AS first_name, 'Customer' AS last_name
),
all_customers AS (
    SELECT customer_id, first_name, last_name
    FROM customer

    UNION ALL

    SELECT customer_id, first_name, last_name
    FROM fake_customer
)
SELECT c.*
FROM all_customers c
LEFT JOIN invoice i ON i.customer_id = c.customer_id
WHERE i.customer_id IS NULL;


-- Get list of customers with their total spend, using COALESCE to replace NULL invoice totals with 0. This ensures that customers with no invoices are still included in the result set with a total spend of 0.
-- COALESCE(SUM(i.total), 0) ==>> "Evaluate SUM(i.total). If the result is NULL, return 0 instead."
SELECT 
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) AS customer_name,
    COALESCE(SUM(i.total), 0) AS total_spend
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spend DESC;



-- Combine the above queries into a single query that computes customer spend with COALESCE when no invoices exist. This query will ensure that customers with no invoices are still included in the result set with a total spend of 0.
WITH fake_customer AS (
    SELECT 9999 AS customer_id, 'Test' AS first_name, 'Customer' AS last_name
),
all_customers AS (
    SELECT customer_id, first_name, last_name
    FROM customer

    UNION ALL

    SELECT customer_id, first_name, last_name
    FROM fake_customer
)
SELECT 
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) AS customer_name,
    COALESCE(SUM(i.total), 0) AS total_spend
FROM all_customers c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spend DESC;
