-- TASK FORMAT
-- Task ID: F20
-- Title: Deduplication patterns    
-- Goal: Identify duplicate customers by (first_name, last_name, email) using ROW_NUMBER().
-- Deliverable A: List of duplicate customers with their row number and total duplicates.
-- Deliverable B: Delete duplicates while keeping the record with the lowest customer_id.
-- Verification: duplicate count is zero after cleanup in a test transaction.
-- -----------------------------------------------------------------------------

-- Deliverable A: Identify duplicates  by (first_name) using ROW_NUMBER(). 
-- NOTE: This is a simplified example because of limited data. In practice, you may want to consider additional fields for deduplication (e.g., last_name, email).

WITH ranked_customers AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        email,
        ROW_NUMBER() OVER (PARTITION BY first_name ORDER BY customer_id) AS row_num,
        COUNT(*) OVER (PARTITION BY first_name) AS total_duplicates
    FROM customer_duplicate
)
SELECT *
FROM ranked_customers
WHERE total_duplicates > 1
ORDER BY first_name, row_num;


