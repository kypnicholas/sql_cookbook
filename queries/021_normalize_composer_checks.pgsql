-- TASK FORMAT
-- Task ID: F21
-- Title: Normalize composer into artist mapping
-- Goal: Create a normalized mapping of track composers to an artist table.
-- Deliverable A: Migration to create artist table and track_composer junction table. 
    -- DONE IN 'migrations/021_normalize_composer.sql'
-- Deliverable B: Backfill artist table and track_composer junction table from existing track.composer data.
    -- DONE IN 'migrations/021_normalize_composer.sql'    
-- Verification: Show sample rows joining track → track_composer → artist (before/after structure)
    -- Count total rows in track_composer.
    -- Show number of tracks with more than one composer.
-- -----------------------------------------------------------------------------

-- Count total rows in track_composer.
SELECT COUNT(*) AS total_rows_in_track_composer
FROM track_composer;

-- Show number of tracks with more than one composer.
SELECT COUNT(*) AS tracks_with_multiple_composers
FROM (
    SELECT track_id
    FROM track_composer
    GROUP BY track_id
    HAVING COUNT(artist_id) > 1
) AS subquery;

-- Show sample rows joining track → track_composer → artist (before/after structure comparison).
SELECT t.track_id, t.name AS track_name, a.artist_id, a.name AS composer_name
FROM track t
JOIN track_composer tc ON t.track_id = tc.track_id
JOIN artist a ON tc.artist_id = a.artist_id
ORDER BY t.track_id
LIMIT 10;

--  “Before/after structure” per track (one row per track, with aggregated composer names)
select t.track_id,t.composer as track_composer_raw,array_agg(distinct a.name order by a.name) as composer_artists
from public.track t
join public.track_composer tc on tc.track_id = t.track_id
join public.artist a on a.artist_id = tc.artist_id
group by t.track_id, t.composer
order by t.track_id
limit 25;

-- Composer_artist verification that there are no composers in track_composer that do not exist in artist table.
SELECT
  SUM(CASE WHEN a.artist_id IS NULL THEN 1 ELSE 0 END)::bigint AS unresolved_artist_links
FROM public.track_composer tc
LEFT JOIN public.artist a
  ON a.artist_id = tc.artist_id;