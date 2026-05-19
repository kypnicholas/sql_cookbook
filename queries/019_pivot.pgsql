/*******************************************************************************
   E19 — Pivoting / crosstab (or FILTER-based pivot)
   
   Purpose: Demonstrate how to pivot data from rows to columns using PostgreSQL's
   FILTER clause or crosstab extension. This is useful for creating summary reports
   where you want to see data across different dimensions as columns.
   
   Expected tasks:
   - Pivot monthly revenue into columns for a small range of months (use FILTER or crosstab extension).
   - If crosstab not available, show manual pivot with SUM(...) FILTER (WHERE date_trunc('month', invoice_date) = '2024-01-01').
********************************************************************************/

-- Example 1: Pivot monthly revenue using FILTER clause (PostgreSQL 9.4+)
-- This shows revenue by country for specific months as separate columns

SELECT 
    billing_country,
    SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-01-01') AS jan_2009_revenue,
    SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-02-01') AS feb_2009_revenue,
    SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-03-01') AS mar_2009_revenue,
    SUM(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-04-01') AS apr_2009_revenue,
    SUM(total) AS total_revenue
FROM 
    invoice
WHERE 
    invoice_date >= '2009-01-01' 
    AND invoice_date < '2009-05-01'
GROUP BY 
    billing_country
ORDER BY 
    total_revenue DESC;


-- Example 2: Pivot customer count by country and year
-- Shows how many customers made purchases in each year

SELECT 
    billing_country,
    COUNT(DISTINCT customer_id) FILTER (WHERE EXTRACT(YEAR FROM invoice_date) = 2009) AS customers_2009,
    COUNT(DISTINCT customer_id) FILTER (WHERE EXTRACT(YEAR FROM invoice_date) = 2010) AS customers_2010,
    COUNT(DISTINCT customer_id) FILTER (WHERE EXTRACT(YEAR FROM invoice_date) = 2011) AS customers_2011,
    COUNT(DISTINCT customer_id) FILTER (WHERE EXTRACT(YEAR FROM invoice_date) = 2012) AS customers_2012,
    COUNT(DISTINCT customer_id) AS total_customers
FROM 
    invoice
GROUP BY 
    billing_country
ORDER BY 
    total_customers DESC;


-- Example 3: Pivot invoice counts by quarter
-- Shows number of invoices per country by quarter

SELECT 
    billing_country,
    COUNT(*) FILTER (WHERE EXTRACT(QUARTER FROM invoice_date) = 1) AS q1_invoices,
    COUNT(*) FILTER (WHERE EXTRACT(QUARTER FROM invoice_date) = 2) AS q2_invoices,
    COUNT(*) FILTER (WHERE EXTRACT(QUARTER FROM invoice_date) = 3) AS q3_invoices,
    COUNT(*) FILTER (WHERE EXTRACT(QUARTER FROM invoice_date) = 4) AS q4_invoices,
    COUNT(*) AS total_invoices
FROM 
    invoice
WHERE 
    EXTRACT(YEAR FROM invoice_date) = 2009
GROUP BY 
    billing_country
ORDER BY 
    total_invoices DESC;


-- Example 4: Pivot average invoice total by month (first 6 months of 2009)
-- Shows average invoice amount for each month

SELECT 
    billing_country,
    ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-01-01'), 2) AS jan_avg,
    ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-02-01'), 2) AS feb_avg,
    ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-03-01'), 2) AS mar_avg,
    ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-04-01'), 2) AS apr_avg,
    ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-05-01'), 2) AS may_avg,
    ROUND(AVG(total) FILTER (WHERE DATE_TRUNC('month', invoice_date) = '2009-06-01'), 2) AS jun_avg,
    ROUND(AVG(total), 2) AS overall_avg
FROM 
    invoice
WHERE 
    invoice_date >= '2009-01-01' 
    AND invoice_date < '2009-07-01'
GROUP BY 
    billing_country
HAVING 
    COUNT(*) >= 3  -- Only show countries with at least 3 invoices
ORDER BY 
    overall_avg DESC;


-- Example 5: Alternative approach using CASE WHEN (works in older PostgreSQL versions)
-- This is the traditional way to pivot before FILTER was introduced

SELECT 
    billing_country,
    SUM(CASE WHEN DATE_TRUNC('month', invoice_date) = '2009-01-01' THEN total ELSE 0 END) AS jan_2009_revenue,
    SUM(CASE WHEN DATE_TRUNC('month', invoice_date) = '2009-02-01' THEN total ELSE 0 END) AS feb_2009_revenue,
    SUM(CASE WHEN DATE_TRUNC('month', invoice_date) = '2009-03-01' THEN total ELSE 0 END) AS mar_2009_revenue,
    SUM(total) AS total_revenue
FROM 
    invoice
WHERE 
    invoice_date >= '2009-01-01' 
    AND invoice_date < '2009-04-01'
GROUP BY 
    billing_country
ORDER BY 
    total_revenue DESC;


/*******************************************************************************
   Notes on Pivoting in PostgreSQL:
   
   1. FILTER Clause (Recommended for PostgreSQL 9.4+):
      - More readable and concise
      - Better performance in some cases
      - Syntax: aggregate_function(...) FILTER (WHERE condition)
   
   2. CASE WHEN Approach (Compatible with older versions):
      - Works in all PostgreSQL versions
      - More verbose but universally compatible
      - Syntax: SUM(CASE WHEN condition THEN value ELSE 0 END)
   
   3. crosstab() Function (tablefunc extension):
      - Requires: CREATE EXTENSION tablefunc;
      - More dynamic but requires extension installation
      - Useful when you don't know column names in advance
      - Not shown here as it requires extension setup
   
   4. Best Practices:
      - Use FILTER for cleaner, more maintainable code
      - Limit the number of pivot columns (typically 3-12)
      - Consider using a reporting tool for highly dynamic pivots
      - Add COALESCE() to handle NULL values if needed
      - Use ROUND() for decimal values to improve readability
********************************************************************************/
