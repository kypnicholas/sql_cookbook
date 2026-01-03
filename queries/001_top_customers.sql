-- 001_top_customers.sql
-- Top N customers by total_spent
SELECT customer_id, first_name, last_name, total_spent
FROM customers
ORDER BY total_spent DESC
LIMIT 10;

SELECT count(customer_id) as customer_count
FROM customers
group by 1;