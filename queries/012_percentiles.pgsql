-- TASK FORMAT
-- Task ID: C12
-- Title: Percentiles and distribution
-- Goal: Use NTILE and percentile_cont to inspect value distribution.
-- Deliverables: quartile assignment, quartile summary, percentile cut points.
-- Verification: q1/median/q3 and tile-level stats are returned.
-- NTILE Definition.
-- NTILE is a window function that divides ordered rows into a specified number of approximately equal groups, or "tiles".
-- Each row is assigned a tile number from 1 to N, where N is the number of tiles specified.
-- It is commonly used for ranking, quartile calculations, and distributing data into equal-sized buckets.

-- 1) Assign each track to a quartile (1..4) using NTILE(4).
-- Quartile 1 = cheapest, Quartile 4 = most expensive (ordered by unit_price ASC).
SELECT
	track_id,
	name,
	unit_price,
	NTILE(4) OVER (ORDER BY unit_price) AS quartile
FROM public.track
ORDER BY quartile, unit_price;

-- 2) Summary: count of tracks, min/max/average price per quartile
SELECT
	quartile,
	COUNT(*) AS tracks_in_quartile,
	MIN(unit_price) AS min_price,
	MAX(unit_price) AS max_price,
	ROUND(AVG(unit_price)::numeric,2) AS avg_price
FROM (
	SELECT unit_price, NTILE(4) OVER (ORDER BY unit_price) AS quartile
	FROM public.track
) t
GROUP BY quartile
ORDER BY quartile;


-- 3) Quartiles per genre (partition by genre_id)
SELECT
	genre_id,
	track_id,
	name,
	unit_price,
	NTILE(4) OVER (PARTITION BY genre_id ORDER BY unit_price) AS genre_quartile
FROM public.track
ORDER BY genre_id, genre_quartile, unit_price;


-- PERCENTILE_CONT DEFINITION.
-- PERCENTILE_CONT is an ordered-set aggregate function that computes a specified percentile value from a set of values.
-- It interpolates between values when the desired percentile falls between two data points.
-- It is often used in statistical analysis to understand the distribution of data.

-- 4) Compute quartile cutpoints using percentile_cont (continuous percentile)
-- This returns the value at each quartile boundary (0.25, 0.5, 0.75)
SELECT
	percentile_cont(0.25) WITHIN GROUP (ORDER BY unit_price) AS q1,
	percentile_cont(0.5)  WITHIN GROUP (ORDER BY unit_price) AS median,
	percentile_cont(0.75) WITHIN GROUP (ORDER BY unit_price) AS q3
FROM public.track;
