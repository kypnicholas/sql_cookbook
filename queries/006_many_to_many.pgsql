-- TASK FORMAT
-- Task ID: B6
-- Title: Many-to-many joins
-- Goal: Query bridge-table relationships between playlists and tracks.
-- Deliverables: playlist track listing, multi-playlist track detection, aggregated playlist names.
-- Verification: Tracks with COUNT(*) > 1 across playlists are returned.
-- Display tracks in a specific playlist.
SELECT track.name AS track_name, playlist.name AS playlist_name
FROM public.track track
INNER JOIN public.playlist_track pt ON track.track_id = pt.track_id
INNER JOIN public.playlist playlist ON pt.playlist_id = playlist.playlist_id
WHERE playlist.name = 'Heavy Metal Classic'
LIMIT 10;


 -- Find tracks that appear in more than one playlist (one row per track)
 SELECT track.track_id, track.name AS track_name, COUNT(*) AS playlist_count
 FROM public.track track
 JOIN public.playlist_track pt ON track.track_id = pt.track_id
 GROUP BY track.track_id, track.name
 HAVING COUNT(*) > 1
 ORDER BY playlist_count DESC
 LIMIT 10;

 -- List all playlists for tracks that belong to multiple playlists.
 SELECT track.track_id, track.name AS track_name, 
				array_agg(playlist.name ORDER BY playlist.name) AS playlists,
				COUNT(playlist.playlist_id) AS playlist_count
 FROM public.track track
 JOIN public.playlist_track pt ON track.track_id = pt.track_id
 JOIN public.playlist playlist ON pt.playlist_id = playlist.playlist_id
 GROUP BY track.track_id, track.name
 HAVING COUNT(playlist.playlist_id) > 1
 ORDER BY playlist_count DESC
 LIMIT 10;

