/*
1) OFFSET pagination (simple, not for large offsets)
   - Use for small tables or simple admin UIs.
*/
-- Simple offset
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
2) Keyset (cursor) pagination — preferred for large tables / user-facing APIs
*/
-- Simple keyset: using a single unique column as cursor
SELECT * FROM public.invoice
WHERE invoice_id > 20
ORDER BY invoice_id
LIMIT 10;





















-- Keyset pagination example
/*
Keyset pagination is MORE efficient for large datasets
because it avoids the performance issues associated with OFFSET.
*/
SELECT * FROM public.invoice
WHERE invoice_id > 20
ORDER BY invoice_id
LIMIT 10;

-- Paginate invoices for customers from a specific country
SELECT * FROM public.invoice
WHERE billing_country = 'Canada' AND invoice_id > 15
ORDER BY invoice_id
LIMIT 10;

-- Paginate with composite keys
SELECT * FROM public.invoice
WHERE (billing_country = 'USA' AND invoice_id > 50)
   OR (billing_country > 'USA')
ORDER BY billing_country, invoice_id
LIMIT 10;

-- Paginate by page number using keyset pagination
/*
To get to page N with page size P, use:
WHERE invoice_id > (N-1)*P
*/
SELECT * FROM public.invoice
WHERE invoice_id > 30  -- For page 4 with page size 10
ORDER BY invoice_id
LIMIT 10;               -- Page size 10

