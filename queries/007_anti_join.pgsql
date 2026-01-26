-- Select customers without invoices --
SELECT * FROM public.customer customer 
LEFT JOIN public.invoice invoice ON customer.customer_id = invoice.customer_id
WHERE invoice.customer_id IS NULL;

-- Select customers without invoices using NOT EXISTS --
SELECT * FROM public.customer customer
WHERE NOT EXISTS (
    SELECT 1 FROM public.invoice invoice 
    WHERE invoice.customer_id = customer.customer_id
);

