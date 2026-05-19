-- TASK FORMAT
-- Task ID: C10
-- Title: ROLLUP, GROUPING SETS, and CUBE
-- Goal: Produce multi-level subtotal reports in a single query family.
-- Deliverables: one ROLLUP, one CUBE, one GROUPING SETS example.
-- Verification: Subtotal/grand-total rows appear with grouping-aware labels.
-- Target: show monthly revenue by country AND state and subtotals using ROLLUP / GROUPING SETS / CUBE.
-- They are GROUP BY extensions for generating multiple grouping levels in one query.
-- Useful for reports that need subtotals without multiple queries or UNIONs.
--
--
-- Explain:
-- - ROLLUP: Used for hierarchical, progressive aggregation.
-- It creates subtotals that roll up from the most detailed level to a grand total.
--
-- - CUBE: Used for all combinations of specified grouping columns, producing a multidimensional summary
--
-- - GROUPING SETS(...): explicit list of grouping sets you want; most flexible,
-- Allows custom combinations (equivalent to enumerating results from ROLLUP/CUBE).
--
-- Key points:
-- - Use ROLLUP for hierarchical subtotals, CUBE for all combinations, and GROUPING SETS for custom groupings.
-- - CUBE generates more rows than ROLLUP because it calculates all possible, non-hierarchical combinations.
-- - These operators are essential for creating comprehensive reports without executing multiple UNION ALL statements.


-- ROLLUP : monthly revenue by country AND state with subtotal per month for all countries and states + grand total.
SELECT
  CASE WHEN GROUPING(date_trunc('month', invoice.invoice_date)) = 1 THEN 'All months'
       ELSE to_char(date_trunc('month', invoice.invoice_date), 'YYYY-MM') END AS month,
  CASE WHEN GROUPING(c.country) = 1 THEN 'All countries' ELSE c.country END AS country,
  CASE WHEN GROUPING(c.state) = 1 THEN 'All states' ELSE c.state END AS state,
  SUM(invoice.total) AS revenue
FROM public.invoice invoice
JOIN public.customer c ON invoice.customer_id = c.customer_id
GROUP BY ROLLUP (date_trunc('month', invoice.invoice_date), c.country, c.state)
ORDER BY month NULLS LAST, country NULLS LAST, state NULLS LAST;
-- NOTE:
-- The expression returns 1 when this row is a subtotal/grand-total row where that column was "rolled up";
-- It returns 0 for regular detail rows where the column is part of the group.
-- If we do not use CASE WHEN and rename the values, we will see NULLs for subtotal/grand-total rows.


-- CUBE example: all combinations (detail + every possible subtotal combination)
SELECT
  CASE WHEN GROUPING(date_trunc('month', invoice.invoice_date)) = 1 THEN 'All months'
       ELSE to_char(date_trunc('month', invoice.invoice_date), 'YYYY-MM') END AS month,
  CASE WHEN GROUPING(c.country) = 1 THEN 'All countries' ELSE c.country END AS country,
  CASE WHEN GROUPING(c.state) = 1 THEN 'All states' ELSE c.state END AS state,
  SUM(invoice.total) AS revenue
FROM public.invoice invoice
JOIN public.customer c ON invoice.customer_id = c.customer_id
GROUP BY CUBE (date_trunc('month', invoice.invoice_date), c.country, c.state)
ORDER BY month NULLS LAST, country NULLS LAST, state NULLS LAST;


-- GROUPING SETS example: explicit control over which subtotals to produce.
SELECT
  CASE WHEN GROUPING(date_trunc('month', invoice.invoice_date)) = 1 THEN 'All months'
       ELSE to_char(date_trunc('month', invoice.invoice_date), 'YYYY-MM') END AS month,
  CASE WHEN GROUPING(c.country) = 1 THEN 'All countries' ELSE c.country END AS country,
  CASE WHEN GROUPING(c.state) = 1 THEN 'All states' ELSE c.state END AS state,
  SUM(invoice.total) AS revenue
FROM public.invoice invoice
JOIN public.customer c ON invoice.customer_id = c.customer_id
GROUP BY GROUPING SETS (
  (date_trunc('month', invoice.invoice_date), c.country, c.state),  -- month + country + state detail
  (date_trunc('month', invoice.invoice_date), c.country),          -- month + country subtotal
  (date_trunc('month', invoice.invoice_date)),                     -- month subtotal
  (c.country, c.state),                                         -- country+state subtotal across months
  (c.country),                                                  -- country subtotal
  ()                                                             -- grand total
)
ORDER BY month NULLS LAST, country NULLS LAST, state NULLS LAST;


-- Count of distinct states per country to assist in understandign the queries above.
SELECT country, count(distinct(state)) as state_count
FROM public.customer 
GROUP BY 1
ORDER BY 2 DESC
;
