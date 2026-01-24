-- Many to many join to retrieve tracks along with their playlists --
SELECT track.name AS track_name, playlist.name AS playlist_name
FROM public.track track
INNER JOIN public.playlist_track pt ON track.track_id = pt.track_id
INNER JOIN public.playlist playlist ON pt.playlist_id = playlist.playlist_id
where playlist.name = 'Heavy Metal Classic'
LIMIT 10;

-- Many to many joint to retrieve tracks that belong to multiple playlists --
SELECT track.name AS track_name, COUNT(playlist.playlist_id) AS playlist_count, playlist.name AS playlist_name
FROM public.track track
INNER JOIN public.playlist_track pt ON track.track_id = pt.track_id
INNER JOIN public.playlist playlist ON pt.playlist_id = playlist.playlist_id
GROUP BY track.track_id, playlist.name
HAVING COUNT(playlist.playlist_id) > 1
LIMIT 10;