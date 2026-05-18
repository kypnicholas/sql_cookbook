--- Basic Queries ---

-- Simple SELECTs and filters -- 
SELECT * FROM public.album LIMIT 100;

SELECT * FROM public.artist LIMIT 100;

SELECT * FROM public.customer WHERE Country = 'Germany' LIMIT 100; 

SELECT first_name, last_name, email FROM public.customer WHERE Country = 'Germany' LIMIT 100;

-- Find all invoices with a total greater than 5.00 --
SELECT * FROM public.invoice WHERE Total > 5.00 LIMIT 100;

-- Find all tracks with 'love' in the name (case insensitive) --
SELECT name, composer FROM public.track WHERE name ILIKE '%love%';