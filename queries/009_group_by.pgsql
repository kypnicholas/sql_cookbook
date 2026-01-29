
-- Revenue per customer --
SELECT customer.customer_id,customer.first_name,customer.last_name, sum(invoice.total) AS total_revenue
 FROM public.customer customer 
LEFT JOIN public.invoice invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY total_revenue DESC
LIMIT 10;

