
-- Example query using JOINs to retrieve track names along with their album titles and artist names--
SELECT track.name,album.title,artist.name
 from public.track track
inner join public.album album on track.album_id = album.album_id
inner join public.artist artist on album.artist_id = artist.artist_id
limit 10;

