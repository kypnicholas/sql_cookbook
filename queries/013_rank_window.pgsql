
-- RANK definition
-- The RANK() window function assigns a unique, sequential integer rank to each row within a query result set partition based on the order defined in the OVER() clause. 
-- Identical values (ties) receive the same rank, and the function skips the next ranking number(s) following a tie.

-- Top track per genre using RANK()

-- Steps:
-- 1) `sales` CTE: compute total quantity sold per track (times_sold).
-- 2) `ranked` CTE: apply `RANK()` partitioned by genre ordered by times_sold.
-- 3) final SELECT: filter to `genre_rank = 1` to return top track(s) per genre.

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

