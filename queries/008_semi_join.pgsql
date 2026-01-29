-- Definition: a semi-join returns rows from the left table that have at least
-- one matching row in the right table, but does not return columns from the
-- right table. It's a boolean existence test, not a full row-pair join.
--
-- Common SQL forms:
---- EXISTS (recommended to avoid duplicate left rows, expresses semi-join)
---- IN (also common)

-- Select artists who have at least one track sold 
SELECT * FROM public.artist artist
WHERE EXISTS (
    SELECT 1 FROM public.album album
    JOIN public.track track ON album.album_id = track.album_id
    JOIN public.invoice_line il ON track.track_id = il.track_id
    WHERE album.artist_id = artist.artist_id
);

-- Select the tracks that belong at least in one playlist --
-- PROBLEM: this query returns duplicate track rows if a track appears in multiple playlists --
SELECT track.track_id, track.name, playlist.name AS playlist_name
FROM public.track track
JOIN public.playlist_track pt ON track.track_id = pt.track_id
JOIN public.playlist playlist ON pt.playlist_id = playlist.playlist_id
ORDER BY track.track_id;

-- SOLUTION: use EXISTS to avoid duplicate track rows --
SELECT track.track_id, track.name
FROM public.track track
WHERE EXISTS (
  SELECT 1
  FROM public.playlist_track pt
  JOIN public.playlist playlist ON pt.playlist_id = playlist.playlist_id
  WHERE pt.track_id = track.track_id
)
ORDER BY track.track_id;

-- ALTERNATIVE: use IN to avoid duplicate track rows --
SELECT track.track_id, track.name
FROM public.track
WHERE track.track_id IN (
  SELECT pt.track_id
  FROM public.playlist_track pt
)
ORDER BY track.track_id;


-- List of playlists per track for tracks that belong to at least one playlist --
-- Avoid deduplication by aggregating playlist names into an array --
SELECT track.track_id, track.name, array_agg(playlist.name) AS playlists
FROM public.track track
JOIN public.playlist_track pt ON track.track_id = pt.track_id
JOIN public.playlist playlist ON pt.playlist_id = playlist.playlist_id
GROUP BY track.track_id, track.name
ORDER BY track.track_id;