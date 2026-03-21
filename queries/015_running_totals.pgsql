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
