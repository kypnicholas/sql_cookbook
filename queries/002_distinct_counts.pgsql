-- TASK FORMAT
-- Task ID: A2
-- Title: DISTINCT and COUNT(DISTINCT)
-- Goal: Measure uniqueness and categorical spread across core dimensions.
-- Deliverables: distinct billing countries, distinct genres, email uniqueness check.
-- Verification: COUNT(*) vs COUNT(DISTINCT email) is returned in one result set.
-- Count the number of transactions per billing country.
SELECT DISTINCT billing_country, COUNT(*) AS "No. of transactions" FROM public.invoice
GROUP BY billing_country
ORDER BY "No. of transactions" DESC;

-- Count the number of distinct billing countries.
SELECT COUNT(DISTINCT billing_country) FROM public.invoice;

-- List distinct genres present in tracks.
SELECT DISTINCT name FROM public.genre;

-- Show emails uniqueness check: COUNT(*) vs COUNT(DISTINCT email).
SELECT 
COUNT(*) AS total_emails,
COUNT(DISTINCT email) AS distinct_emails   
FROM public.customer;
