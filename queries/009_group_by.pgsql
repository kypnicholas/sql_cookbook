
-- Revenue per customer --
SELECT customer.customer_id,customer.first_name,customer.last_name, sum(invoice.total) AS total_revenue
 FROM public.customer customer 
LEFT JOIN public.invoice invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Orders per country --
SELECT customer.country, count(invoice.invoice_id) AS total_orders, sum(invoice.total) AS total_revenue
 FROM public.customer customer      
LEFT JOIN public.invoice invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.country
ORDER BY total_orders DESC
LIMIT 10;

-- Genres with revenue > 100USD --
SELECT genre.name AS genre_name, 
    SUM(il.unit_price * il.quantity) AS genre_revenue,
    to_char(SUM(il.unit_price * il.quantity), 'FM$999,999,999.00') AS genre_revenue_usd
FROM public.genre genre
LEFT JOIN public.track track ON genre.genre_id = track.genre_id
LEFT JOIN public.invoice_line il ON track.track_id = il.track_id
GROUP BY genre.name
HAVING SUM(il.unit_price * il.quantity) > 100
ORDER BY genre_revenue DESC
LIMIT 10;