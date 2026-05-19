-- TASK FORMAT
-- Task ID: A3
-- Title: Pagination and keyset patterns
-- Goal: Compare OFFSET/LIMIT pagination against keyset pagination.
-- Deliverables: OFFSET example, keyset example, date-based page example.
-- Verification: Stable ordered pages are returned for each strategy.
/*
OFFSET pagination (simple, not for large offsets)
   - Use for small tables or simple admin UIs.
*/
-- Simple offset.
SELECT * FROM public.invoice
ORDER BY invoice_id
LIMIT 10 OFFSET 20; -- page 3 

-- COUNT with paging (expensive for large tables)
-- Returns total_count with each row; costly because it computes full count.
SELECT *, COUNT(*) OVER() AS total_count
FROM public.invoice
ORDER BY invoice_id
LIMIT 10 OFFSET 0;


/*
Keyset (cursor) pagination â€” preferred for large tables / user-facing APIs
*/
-- Simple keyset: using a single unique column as cursor.
SELECT * FROM public.invoice
WHERE invoice_id > 20      -- Page 3 with page size 10
ORDER BY invoice_id
LIMIT 10;                  -- Page size 10

-- Paginate with composite keys.
SELECT * FROM public.invoice
WHERE (billing_country = 'USA' AND invoice_id > 50)  -- Page 6 with page size 10
   OR (billing_country > 'USA')
ORDER BY billing_country, invoice_id
LIMIT 10;

-- Paginate by date.
SELECT * FROM public.invoice
WHERE invoice_date > '2022-01-01'
ORDER BY invoice_date, invoice_id
LIMIT 10;
