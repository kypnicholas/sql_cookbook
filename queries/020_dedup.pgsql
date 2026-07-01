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



-- Deliverable B: Delete duplicates while keeping the record with the lowest customer_id.
-- PROCEED WITH CAUTION. It's recommended to run this in a transaction and verify the results before committing.

BEGIN; 
SELECT 'Deleting duplicates...' AS action;

-- 1) PREVIEW ONLY step to identify duplicates. 
--    The same logic is repeated below to delete customers. 
WITH ranked AS (
  SELECT
    customer_id,
    first_name,
    ROW_NUMBER() OVER (
      PARTITION BY first_name
      ORDER BY customer_id ASC
    ) AS rn
  FROM customer_duplicate
)
SELECT
  customer_id,
  first_name
FROM ranked
WHERE rn > 1
ORDER BY first_name, customer_id;

-- 2) Delete duplicates (everything with rn > 1). 
--    The selection of customers is repeated here to ensure the delete is based on the same logic as the preview.
WITH ranked AS (
  SELECT
    customer_id,
    ROW_NUMBER() OVER (
      PARTITION BY first_name
      ORDER BY customer_id ASC
    ) AS rn
  FROM customer_duplicate
)
DELETE FROM customer_duplicate cd
USING ranked r
WHERE cd.customer_id = r.customer_id
  AND r.rn > 1;

-- 3) Verify how many rows were removed.
--    Compare remaining counts per first_name (should have max one row per first_name)
SELECT
  first_name,
  COUNT(*) AS remaining_rows
FROM customer_duplicate
GROUP BY first_name
HAVING COUNT(*) > 1;

-- If the last query returns 0 rows, you're good.
-- Then commit; otherwise ROLLBACK.
-- COMMIT;
-- ROLLBACK;