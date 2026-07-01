-- TASK FORMAT
-- Task ID: E19
-- Title: Pivoting and crosstab fallback
-- Goal: Build a three-month revenue pivot with a tablefunc.crosstab path and a no-extension fallback.
-- Deliverable A: Monthly revenue pivot for three months using tablefunc.crosstab (if extension available).
-- Deliverable B: Equivalent pivot using SUM(...) FILTER (WHERE ...) without extension.
-- Verification: Both approaches use the same three months and produce the same totals.
-- -----------------------------------------------------------------------------
-- Pivoting definition.
-- Pivoting rotates row values into columns so month-over-month comparisons are easier to read.
-- This template keeps the month window logic shared so both approaches stay aligned.
-- -----------------------------------------------------------------------------


-- Deliverable A: Pivot using tablefunc.crosstab

CREATE EXTENSION IF NOT EXISTS tablefunc;

-- anchor to dataset's latest invoice month so this works for Chinook
-- COALESCE is used to ensure that if a month has no revenue, it will still show as 0 instead of NULL. 
SELECT
  COALESCE(m1,0) AS revenue_m_minus2,
  COALESCE(m2,0) AS revenue_m_minus1,
  COALESCE(m3,0) AS revenue_m_current
FROM (
  SELECT * FROM crosstab(
    $$
      SELECT
        'revenue' AS metric,
        to_char(date_trunc('month', invoice_date), 'YYYY-MM') AS month_label,
        SUM(total)::numeric AS revenue
      FROM invoice
      WHERE invoice_date >= (SELECT date_trunc('month', max(invoice_date)) - INTERVAL '2 months' FROM invoice)
      GROUP BY 1,2
      ORDER BY 1,2
    $$,
    $$
      WITH base AS (
        SELECT date_trunc('month', max(invoice_date)) AS m
        FROM invoice
      )
    -- Generate the three months to pivot on, in order from oldest to newest.
    -- This ensures that even if a month has no revenue, it will still appear in the pivot.
      SELECT to_char(m - INTERVAL '2 months', 'YYYY-MM') AS month
      FROM base
      UNION ALL
      SELECT to_char(m - INTERVAL '1 month', 'YYYY-MM') AS month
      FROM base
      UNION ALL
      SELECT to_char(m, 'YYYY-MM') AS month
      FROM base;
    $$
  ) AS ct(metric text, m1 numeric, m2 numeric, m3 numeric)
) t;
