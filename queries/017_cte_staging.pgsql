------------------------------------------------------------------------------------------------------
-- CTE Definition
-- A Common Table Expression (CTE) is a temporary result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. 
-- It is defined using the WITH clause and can be used to simplify complex queries, improve readability, and enable recursive queries.
-- It improves clarity by breaking complex queries into logical steps, making each transformation explicit and easier to debug or modify.
------------------------------------------------------------------------------------------------------
-- CTE vs Subquery
-- CTEs and subqueries both allow you to break down complex queries, but they have some differences:
-- 1. Readability: CTEs can be easier to read and understand, especially when dealing with multiple levels of nesting, as they allow you to name intermediate result sets.
-- 2. Reusability: CTEs can be referenced multiple times within the same query, while subqueries are typically used once and then you need to repeat the same logic.
-- 3. Performance: In some cases, CTEs may be optimized differently than subqueries, but this can depend on the database engine and the specific query. 
--                 Generally, CTEs are not materialized and are optimized as part of the overall query plan, while subqueries may be executed separately.
-- 4. Recursive Queries: CTEs support recursion, allowing you to perform hierarchical queries, while subqueries do not have this capability.        
------------------------------------------------------------------------------------------------------

-- TASK: Rewrite a multi-join aggregation query using CTEs for clarity and maintainability.
--
-- Identify an existing query (e.g., total sales per artist joining tracks, albums, invoice_items) that uses multiple joins and aggregations.
-- Rewrite this query using at least two CTEs:
--   1. First CTE: Stage a join between tracks, albums, and artists.
--   2. Second CTE: Aggregate sales (SUM(invoice_items.unit_price * invoice_items.quantity)) per artist.
--   3. Final SELECT: Join the CTEs to produce the final result.

-- NOTES:
-- The first CTE is a Standalone CTE 
-- The second CTE is a Dependent/ Nested CTE that references the first CTE. 

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
        trackartist.artist_name,
        SUM(il.unit_price * il.quantity) AS total_sales
    FROM TrackArtist trackartist
    JOIN invoice_line il ON trackartist.track_id = il.track_id
    GROUP BY trackartist.artist_id, trackartist.artist_name
)
SELECT
    artist_id,
    artist_name,
    total_sales
FROM ArtistSales
ORDER BY total_sales DESC;

