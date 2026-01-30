-- Target: show monthly revenue by country and subtotals using ROLLUP / GROUPING SETS / CUBE. 
-- They are GROUP BY extensions for generating multiple grouping levels in one query.
-- Useful for reports that need subtotals without multiple queries or UNIONs.
-- 
-- Explain:
-- - ROLLUP: Used for hierarchical, progressive aggregation (e.g., time periods: year > quarter > month).
--   It creates subtotals that roll up from the most detailed level to a grand total.
--
-- - CUBE: Used for all combinations of specified grouping columns, producing a multidimensional summary
--   (e.g., all combinations of month and country)
--
-- - GROUPING SETS(...): explicit list of grouping sets you want; most flexible,
--   allows custom combinations (equivalent to enumerating results from ROLLUP/CUBE).
--
-- Key takeaways:
-- - Use ROLLUP for hierarchical subtotals, CUBE for all combinations, and GROUPING SETS for custom groupings.
-- - CUBE generates more rows than ROLLUP because it calculates all possible, non-hierarchical combinations.
-- - These operators are essential for creating comprehensive reports without executing multiple UNION ALL statements. 


-- ROLLUP : monthly revenue by country with subtotal per month for all countries and grand total for all countries and months.
SELECT
  CASE WHEN GROUPING(date_trunc('month', inv.invoice_date)) = 1 THEN 'All months'       
       ELSE to_char(date_trunc('month', inv.invoice_date), 'YYYY-MM') END AS month,
  CASE WHEN GROUPING(c.country) = 1 THEN 'All countries' ELSE c.country END AS country,
  SUM(inv.total) AS revenue
FROM public.invoice inv
JOIN public.customer c ON inv.customer_id = c.customer_id
GROUP BY ROLLUP (date_trunc('month', inv.invoice_date), c.country)
ORDER BY month NULLS LAST, country NULLS LAST;
-- NOTE:
-- The expression returns 1 when this row is a subtotal/grand-total row where that column was "rolled up"; 
-- it returns 0 for regular detail rows where the column is part of the group.
-- If we do not use CASE WHEN and rename the values, we will see NULLs for subtotal/grand-total rows.


-- CUBE example: all combinations (detail, month-only, country-only, grand total)
SELECT
  CASE WHEN GROUPING(date_trunc('month', inv.invoice_date)) = 1 THEN 'All months'
       ELSE to_char(date_trunc('month', inv.invoice_date), 'YYYY-MM') END AS month,
  CASE WHEN GROUPING(c.country) = 1 THEN 'All countries' ELSE c.country END AS country,
  SUM(inv.total) AS revenue
FROM public.invoice inv
JOIN public.customer c ON inv.customer_id = c.customer_id
GROUP BY CUBE (date_trunc('month', inv.invoice_date), c.country)
ORDER BY month NULLS LAST, country NULLS LAST;


-- GROUPING SETS example: explicit control over which subtotals to produce
SELECT
  CASE WHEN GROUPING(date_trunc('month', inv.invoice_date)) = 1 THEN 'All months'
       ELSE to_char(date_trunc('month', inv.invoice_date), 'YYYY-MM') END AS month,
  CASE WHEN GROUPING(c.country) = 1 THEN 'All countries' ELSE c.country END AS country,
  SUM(inv.total) AS revenue
FROM public.invoice inv
JOIN public.customer c ON inv.customer_id = c.customer_id
GROUP BY GROUPING SETS (
  (date_trunc('month', inv.invoice_date), c.country),  -- month + country detail
  (date_trunc('month', inv.invoice_date)),             -- month subtotal
  (c.country),                                         -- country subtotal (across months)
  ()                                                   -- grand total
)
ORDER BY month NULLS LAST, country NULLS LAST;


