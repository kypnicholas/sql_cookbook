-- TASK FORMAT
-- Task ID: D16
-- Title: Window percentiles and distributions
-- Goal: Use PERCENT_RANK and CUME_DIST for comparative analytics.
-- Deliverables: customer spend percentile ranking and track price cumulative distribution.
-- Verification: Highest spender has top percent_rank and highest prices approach cume_dist 1.

-- PERCENT_RANK() definition.
-- The PERCENT_RANK() window function calculates the relative rank of a row within a partition of a result set, expressed as a percentage.
-- It is often used to determine the position of a value within a sorted list of values, such as finding the percentile rank of a value in a dataset.

-- Rank customers by total spend (across customers).
WITH customer_spend AS (
    SELECT
        customer.customer_id,
        customer.first_name,
        customer.last_name,
        COALESCE(SUM(invoice.total), 0) AS total_spent
    FROM public.customer customer
    LEFT JOIN public.invoice invoice ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, customer.first_name, customer.last_name
)
SELECT
    customer_id,
    first_name,
    last_name,
    total_spent,
    PERCENT_RANK() OVER (ORDER BY total_spent) AS percent_rank
FROM customer_spend
ORDER BY total_spent DESC, customer_id;



-- CUME_DIST() definition.
-- The CUME_DIST() window function calculates the cumulative distribution of a value within a partition of a result set, expressed as a percentage.
-- It is often used to determine the percentage of rows that have a value less than or equal to the current row's value,.
-- Such as finding the cumulative distribution of a value in a dataset.

-- Cumulative distribution of tracks by unit price.
SELECT
    track_id,
    name,
    unit_price,
    CUME_DIST() OVER (ORDER BY unit_price) AS cume_dist
FROM public.track
ORDER BY unit_price, track_id;
