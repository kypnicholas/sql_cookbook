-- TASK FORMAT
-- Task ID: C11
-- Title: FILTER aggregates
-- Goal: Compute conditional aggregates without multiple query passes.
-- Deliverables: WHERE vs FILTER comparison and conditional count/sum examples.
-- Verification: Multiple conditional metrics are returned in single-row summaries.

-- WHERE vs FILTER in aggregate functions.

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

-- Conditional example with COUNT and FILTER:
SELECT 
    COUNT(*) AS total_invoices,
    COUNT(*) FILTER (WHERE invoice.total > 50) AS high_value_invoices,
    COUNT(*) FILTER (WHERE invoice.total <= 50) AS low_value_invoices
FROM public.invoice invoice;



