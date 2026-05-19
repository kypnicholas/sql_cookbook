-- TASK FORMAT
-- Task ID: D13
-- Title: ROW_NUMBER, RANK, DENSE_RANK
-- Goal: Compare ranking window functions and tie behavior.
-- Deliverables: top-selling track per genre using each ranking function.
-- Verification: Tie handling differs correctly across rank variants.
-- Top-selling track per genre using RANK()

-- RANK definition.
-- The RANK() window function assigns a unique, sequential integer rank to each row within a query result set partition based on the order defined in the OVER() clause.
-- Identical values (ties) receive the same rank, and the function skips the next ranking number(s) following a tie.


-- Steps:
-- 1) `Sales` CTE: compute total sales per track (times_sold).
-- 2) `Ranked` CTE: assigns a rank (genre_rank) to each track within its genre, ordered by times_sold descending.
-- 3) Final SELECT: filter to `genre_rank = 1` to return highest-selling track(s) per genre.

-- NOTE: WITH clause is used to define Common Table Expressions (CTEs).
-- When added to the start of a query, it allows you to create temporary result sets that can be referenced within the main query. CTEs improve readability and organization of complex queries.

WITH sales AS (
	SELECT
		genre.name AS genre,
		track.name AS track_name,
		artist.name AS artist,
		SUM(il.quantity) AS times_sold
	FROM invoice_line il
	JOIN track track ON il.track_id = track.track_id
	LEFT JOIN genre genre ON track.genre_id = genre.genre_id
	LEFT JOIN album album ON track.album_id = album.album_id
	LEFT JOIN artist artist ON album.artist_id = artist.artist_id
	GROUP BY genre.name, track.name, artist.name
), ranked AS (
	SELECT
		genre,
		track_name,
		artist,
		times_sold,
		RANK() OVER (PARTITION BY genre ORDER BY times_sold DESC) AS genre_rank
	FROM sales
)
SELECT genre, track_name, artist, times_sold
FROM ranked
WHERE genre_rank = 1
ORDER BY genre;



-- Top-selling track per genre using DENSE_RANK()

-- DENSE_RANK definition.
-- The DENSE_RANK() window function is similar to RANK(), but it does not skip ranking numbers when there are ties.
-- Steps are the same as above, but we use DENSE_RANK() instead of RANK().

WITH sales AS (
	SELECT
		genre.name AS genre,
        track.name AS track_name,
        artist.name AS artist,
        SUM(il.quantity) AS times_sold
	FROM invoice
    JOIN invoice_line il ON invoice.invoice_id = il.invoice_id
    JOIN track track ON il.track_id = track.track_id
    LEFT JOIN genre genre ON track.genre_id = genre.genre_id
    LEFT JOIN album album ON track.album_id = album.album_id
    LEFT JOIN artist artist ON album.artist_id = artist.artist_id
    GROUP BY genre.name, track.name, artist.name
), ranked AS (
    SELECT
        genre,
        track_name,
        artist,
        times_sold,
        DENSE_RANK() OVER (PARTITION BY genre ORDER BY times_sold DESC) AS genre_rank
    FROM sales
)
SELECT genre, track_name, artist, times_sold
FROM ranked
WHERE genre_rank = 1
ORDER BY genre;



-- Top-selling track per genre using ROW_NUMBER()
-- ROW_NUMBER definition.
-- The ROW_NUMBER() window function assigns a unique sequential integer to each row within a query result set partition, without regard to ties.
-- Steps are the same as above, but we use ROW_NUMBER() instead of RANK().

WITH sales AS (
    SELECT
        genre.name AS genre,
        track.name AS track_name,
        artist.name AS artist,
        SUM(il.quantity) AS times_sold
    FROM invoice
    JOIN invoice_line il ON invoice.invoice_id = il.invoice_id
    JOIN track track ON il.track_id = track.track_id
    LEFT JOIN genre genre ON track.genre_id = genre.genre_id
    LEFT JOIN album album ON track.album_id = album.album_id
    LEFT JOIN artist artist ON album.artist_id = artist.artist_id
    GROUP BY genre.name, track.name, artist.name
), ranked AS (
    SELECT
        genre,
        track_name,
        artist,
        times_sold,
        ROW_NUMBER() OVER (PARTITION BY genre ORDER BY times_sold DESC) AS genre_rank
    FROM sales
)
SELECT genre, track_name, artist, times_sold
FROM ranked
WHERE genre_rank = 1
ORDER BY genre;
