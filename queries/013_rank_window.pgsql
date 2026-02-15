
-- Top track per genre using RANK()
-- RANK() assigns the same rank to ties, and leaves gaps in the ranking sequence for subsequent ranks.

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

-- Notes:
-- - `RANK()` returns ties (multiple tracks with the same top `times_sold`).
-- - If you want exactly one track per genre, use `ROW_NUMBER()` instead.
-- - `LIMIT` is not used here because it would cap the whole result set, not per-genre.
-- - PostgreSQL alternatives: `DISTINCT ON (genre)` or a `LATERAL ... LIMIT 1` per genre.
