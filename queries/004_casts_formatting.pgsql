-- TASK FORMAT
-- Task ID: A4
-- Title: Casting and formatting
-- Goal: Practice explicit and shorthand casts plus presentation formatting.
-- Deliverables: integer cast, currency formatting, milliseconds to minutes/seconds conversion.
-- Verification: Converted numeric/time fields appear alongside original values.
-- Cast the 'total' column from numeric to integer.
-- And format it as currency.
SELECT *, TO_CHAR(total, 'FM$999,999.00') AS total_formatted, CAST(total AS integer) AS total_int
FROM public.invoice
LIMIT 10;

-- Alternative PostgreSQL shorthand:
SELECT *, total::integer AS total_int
FROM public.invoice
LIMIT 10;


-- Cast track miliseconds to minutes and seconds.
SELECT *, CAST (milliseconds / 60000 AS integer) AS minutes,
       CAST ((milliseconds % 60000) / 1000 AS integer) AS seconds
FROM public.track
LIMIT 10;

