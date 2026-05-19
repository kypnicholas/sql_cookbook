-- TASK FORMAT
-- Task ID: B7
-- Title: Anti-join patterns
-- Goal: Find rows on the left side with no matching rows on the right side.
-- Deliverables: LEFT JOIN IS NULL and NOT EXISTS versions for customers and tracks.
-- Verification: Result sets contain only non-matching entities.
-- Definition: an anti-join returns rows from the left table that have NO.
-- Matching rows in the right table. Common SQL expressions that implement.
-- Anti-joins are `NOT EXISTS` (recommended) and `LEFT JOIN ... WHERE right IS NULL`.
--
-- Common SQL forms:
-- - NOT EXISTS (recommended)
-- - LEFT JOIN .. IS NULL (anti-join equivalent)

-- Select customers without invoices.
SELECT * FROM public.customer customer 
LEFT JOIN public.invoice invoice ON customer.customer_id = invoice.customer_id
WHERE invoice.customer_id IS NULL;

-- Select customers without invoices using NOT EXISTS.
SELECT * FROM public.customer customer
WHERE NOT EXISTS (
    SELECT 1 FROM public.invoice invoice 
    WHERE invoice.customer_id = customer.customer_id
);

-- Select tracks that have never been sold.
SELECT * FROM public.track track
LEFT JOIN public.invoice_line il ON track.track_id = il.track_id
WHERE il.track_id IS NULL;

-- Select tracks that have never been sold using NOT EXISTS.
SELECT * FROM public.track track
WHERE NOT EXISTS (
    SELECT 1 FROM public.invoice_line il 
    WHERE il.track_id = track.track_id
);

