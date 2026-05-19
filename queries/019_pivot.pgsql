-- TASK FORMAT
-- Task ID: E19
-- Title: Pivoting and crosstab fallback
-- Goal: Build a three-month revenue pivot with a tablefunc.crosstab path and a no-extension fallback.
-- Deliverables: crosstab monthly revenue pivot; FILTER monthly revenue pivot; matching month columns and totals.
-- Verification: Both approaches use the same three months and produce the same totals.
-- -----------------------------------------------------------------------------
-- Pivoting definition.
-- Pivoting rotates row values into columns so month-over-month comparisons are easier to read.
-- This template keeps the month window logic shared so both approaches stay aligned.
-- -----------------------------------------------------------------------------

-- Shared month window: first three invoice months in the dataset.
WITH month_window AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', invoice_date), 'YYYY-MM') AS month_key,
        ROW_NUMBER() OVER (
            ORDER BY TO_CHAR(DATE_TRUNC('month', invoice_date), 'YYYY-MM')
        ) AS rn
    FROM invoice
    GROUP BY 1
    ORDER BY 1
    LIMIT 3
),
monthly_revenue AS (
    SELECT
        mw.rn,
        mw.month_key,
        SUM(il.unit_price * il.quantity) AS revenue
    FROM month_window mw
    JOIN invoice i
        ON TO_CHAR(DATE_TRUNC('month', i.invoice_date), 'YYYY-MM') = mw.month_key
    JOIN invoice_line il ON il.invoice_id = i.invoice_id
    GROUP BY mw.rn, mw.month_key
),
pivot_filter AS (
    SELECT
        MAX(month_key) FILTER (WHERE rn = 1) AS month_1,
        MAX(month_key) FILTER (WHERE rn = 2) AS month_2,
        MAX(month_key) FILTER (WHERE rn = 3) AS month_3,
        SUM(revenue) FILTER (WHERE rn = 1) AS month_1_revenue,
        SUM(revenue) FILTER (WHERE rn = 2) AS month_2_revenue,
        SUM(revenue) FILTER (WHERE rn = 3) AS month_3_revenue
    FROM monthly_revenue
)
SELECT *
FROM pivot_filter;

-- Optional crosstab path (run only when tablefunc is available).
-- CREATE EXTENSION IF NOT EXISTS tablefunc;
--
-- SELECT *
-- FROM crosstab(
--   $$
--   WITH month_window AS (
--       SELECT
--           TO_CHAR(DATE_TRUNC('month', invoice_date), 'YYYY-MM') AS month_key,
--           ROW_NUMBER() OVER (
--               ORDER BY TO_CHAR(DATE_TRUNC('month', invoice_date), 'YYYY-MM')
--           ) AS rn
--       FROM invoice
--       GROUP BY 1
--       ORDER BY 1
--       LIMIT 3
--   ),
--   monthly_revenue AS (
--       SELECT
--           'revenue'::text AS row_name,
--           mw.rn::text AS category,
--           SUM(il.unit_price * il.quantity)::numeric AS value
--       FROM month_window mw
--       JOIN invoice i
--           ON TO_CHAR(DATE_TRUNC('month', i.invoice_date), 'YYYY-MM') = mw.month_key
--       JOIN invoice_line il ON il.invoice_id = i.invoice_id
--       GROUP BY mw.rn
--       ORDER BY mw.rn
--   )
--   SELECT row_name, category, value
--   FROM monthly_revenue
--   ORDER BY 1, 2
--   $$,
--   $$VALUES ('1'), ('2'), ('3')$$
-- ) AS pivot_crosstab (
--   row_name text,
--   month_1_revenue numeric,
--   month_2_revenue numeric,
--   month_3_revenue numeric
-- );
