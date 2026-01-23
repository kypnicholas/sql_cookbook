
-- Example query using JOINs to retrieve track names along with their album titles and artist names--
SELECT track.name,album.title,artist.name
 from public.track track
inner join public.album album on track.album_id = album.album_id
inner join public.artist artist on album.artist_id = artist.artist_id
limit 10;

-- Join albums with their tracks using LEFT JOIN to show albums without tracks--
SELECT album.title AS album_title, track.name AS track_name FROM public.album album
left join public.track track on album.album_id = track.album_id
where track.album_id IS NULL
limit 5;


