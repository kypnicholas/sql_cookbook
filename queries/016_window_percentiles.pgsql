
-- PERCENT_RANK() definition
-- The PERCENT_RANK() window function calculates the relative rank of a row within a partition of a result set, expressed as a percentage. 
-- It is often used to determine the position of a value within a sorted list of values, such as finding the percentile rank of a value in a dataset.

SELECT
    customer_id,
    total,
    PERCENT_RANK() OVER (PARTITION BY customer_id ORDER BY total) AS percent_rank
FROM invoice
ORDER BY customer_id, total;







-- CUME_DIST() definition
-- The CUME_DIST() window function calculates the cumulative distribution of a value within a partition of a result set, expressed as a percentage. 
-- It is often used to determine the percentage of rows that have a value less than or equal to the current row's value, 
-- such as finding the cumulative distribution of a value in a dataset.

