------------------------------------------------------------------------------------------------------
-- CTE Definition
-- A Common Table Expression (CTE) is a temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 
-- It is defined using the WITH clause and can be used to simplify complex queries, improve readability, and enable recursive queries.
-- It improves clarity by breaking complex queries into logical steps, making each transformation explicit and easier to debug or modify.
------------------------------------------------------------------------------------------------------


-- Task: Rewrite a multi-join aggregation query using CTEs for clarity and maintainability.
--
-- Identify an existing query (e.g., total sales per artist joining tracks, albums, invoice_items) that uses multiple joins and aggregations.
-- Rewrite this query using at least two CTEs:
--   1. First CTE: Stage a join between tracks, albums, and artists.
--   2. Second CTE: Aggregate sales (SUM(invoice_items.unit_price * invoice_items.quantity)) per artist.
--   3. Final SELECT: Join the CTEs to produce the final result.

WITH TrackArtist AS (
    SELECT
        t.track_id,
        a.artist_id,
        a.name AS artist_name
    FROM track t
    JOIN album al ON t.album_id = al.album_id
    JOIN artist a ON al.artist_id = a.artist_id
),
ArtistSales AS (
    SELECT
        trackartist.artist_id,
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM TrackArtist trackartist
    JOIN invoice_line il ON trackartist.track_id = il.track_id
    GROUP BY trackartist.artist_id
)
SELECT
    artistsales.artist_id,
    trackartist.artist_name,
    artistsales.total_sales
FROM ArtistSales artistsales
JOIN TrackArtist trackartist ON artistsales.artist_id = trackartist.artist_id; 

