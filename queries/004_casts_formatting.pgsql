-- Cast the 'total' column from numeric to integer --
-- and format it as currency--
SELECT *, TO_CHAR(total, 'FM$999,999.00') AS total_formatted, CAST(total AS integer) AS total_int
FROM public.invoice
LIMIT 10;

-- Alternative PostgreSQL shorthand:
SELECT *, total::integer AS total_int
FROM public.invoice
LIMIT 10;


-- Cast track miliseconds to minutes and seconds--
SELECT *, CAST (milliseconds / 60000 AS integer) AS minutes,
       CAST ((milliseconds % 60000) / 1000 AS integer) AS seconds
FROM public.track
LIMIT 10;
