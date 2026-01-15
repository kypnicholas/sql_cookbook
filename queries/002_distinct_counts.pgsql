-- Count the number of transactions per billing country -- 
SELECT DISTINCT billing_country, COUNT(*) AS "No. of transactions" FROM public.invoice
GROUP BY billing_country
ORDER BY "No. of transactions" DESC;

-- Count the number of distinct billing countries --
SELECT COUNT(DISTINCT billing_country) FROM public.invoice;