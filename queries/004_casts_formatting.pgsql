-- Cast the 'total' column from numeric to integer --
SELECT *, CAST(total AS integer) AS total_int
FROM public.invoice
LIMIT 10;

-- Alternative PostgreSQL shorthand:
SELECT *, total::integer AS total_int
FROM public.invoice
LIMIT 10;