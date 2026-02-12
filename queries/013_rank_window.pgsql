
-- Top track per genre using RANK()
-- RANK() assigns the same rank to ties, and leaves gaps in the ranking sequence for subsequent ranks.

SELECT
		genres.name AS genre,
		track.name AS track_name,
		SUM(il.quantity) AS times_sold
	FROM invoice_line il
	JOIN track track ON il.track_id = track.track_id
	JOIN genre genres ON track.genre_id = genres.genre_id
	GROUP BY genres.name, track.name
    ORDER BY genres.name, times_sold DESC
    limit 5;