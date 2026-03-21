-- Running total of customer spend: SUM(total) OVER (PARTITION BY customer_id ORDER BY invoice_date).

-- Running total definition
-- A running total, also known as a cumulative sum, is a sequence of partial sums of a given data set. 
-- You can calculate a running total using the SUM() window function combined with an appropriate OVER() clause to define the partitioning and ordering of the data.

SELECT
    customer_id,
    invoice_id,
    invoice_date,
    total,
    SUM(total) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS running_total
FROM invoice
ORDER BY customer_id, invoice_date;



-- 7-day rolling revenue using RANGE or ROWS BETWEEN.

-- Rolling total definition
-- A rolling total, also known as a moving sum, is a calculation that provides the sum of a specified number of consecutive data points in a dataset. 
-- You can calculate a rolling total using the SUM() window function combined with an appropriate OVER() clause that defines the range of rows to include in the calculation, 
-- such as ROWS BETWEEN or RANGE BETWEEN.

SELECT
    invoice_date,
    total,
    SUM(total) OVER (ORDER BY invoice_date RANGE BETWEEN INTERVAL '6 days' PRECEDING AND CURRENT ROW) AS rolling_7_day_revenue
FROM invoice
ORDER BY invoice_date;



-- Example query that will show, for each invoice, exactly which rows are included in its 7-day rolling sum window. 
-- This uses a lateral join (CROSS JOIN LATERAL) for debugging:

-- CROSS JOIN LATERAL definition
-- A CROSS JOIN LATERAL allows you to join each row from the left table with a set of rows returned by a subquery that can reference columns from the left table. 
-- It is often used to perform calculations that depend on the current row's values, such as calculating a rolling total or performing a lookup based on the current row's data.

SELECT
    i.invoice_date,
    i.total,
    SUM(w.total) AS rolling_7_day_revenue,
    ARRAY_AGG(w.invoice_date) AS included_dates
FROM invoice i
CROSS JOIN LATERAL (
    SELECT total, invoice_date
    FROM invoice
    WHERE invoice_date BETWEEN i.invoice_date - INTERVAL '6 days' AND i.invoice_date
) w
GROUP BY i.invoice_date, i.total
ORDER BY i.invoice_date;