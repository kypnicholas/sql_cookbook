
-- WHERE vs FILTER in aggregate functions

-- WHERE example:
-- Return the total USA revenue.
-- NOTE: This is a simple aggregate WITHOUT filtering syntax.
-- Useful when you only need one condition. For multiple conditions use FILTER.
SELECT SUM(total) as usa_revenue 
FROM public.invoice
WHERE billing_country = 'USA'
;

-- FILTER example:
-- Return the total revenue as well as the USA and Canada revenue in one query.
SELECT 
    SUM(total) AS total_revenue,
    SUM(total) FILTER (WHERE billing_country = 'USA') AS usa_revenue,
    SUM(total) FILTER (WHERE billing_country = 'Canada') AS canada_revenue
FROM public.invoice;
