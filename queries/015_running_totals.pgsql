

-- Running total of customer spend: SUM(total) OVER (PARTITION BY customer_id ORDER BY invoice_date).

-- Running total definition
-- A running total, also known as a cumulative sum, is a sequence of partial sums of a given data set. 
-- You can calculate a running total using the SUM() window function combined with an appropriate OVER() clause to define the partitioning and ordering of the data.





