/*******************************************************************************
    Create table 'artist' and junction table track_composer to normalize 
    many-to-many relationship between track and composer.
********************************************************************************/

-- Create junction table to normalize many-to-many relationship between track and composer
CREATE TABLE public.track_composer (
    track_id int NOT NULL REFERENCES public.track(track_id) ON DELETE CASCADE,
    artist_id bigint NOT NULL REFERENCES public.artist(artist_id) ON DELETE CASCADE,
    PRIMARY KEY (track_id, artist_id)
);

/*** NOT USED AS artist table already exists in the schema.

-- Backfill artist table with distinct composer names from track.composer
-- Use regexp_split_to_table to split composer names on special characters (comma, ampersand, slash) and trim whitespace. 
-- Cross join lateral is used to apply the split function to each row of the track table. It returns a set of rows for each composer name, which are then inserted into the artist table. 
INSERT INTO artist (name)
SELECT DISTINCT trimmed_name
FROM (
    SELECT TRIM(x) AS trimmed_name
    FROM track 
    CROSS JOIN LATERAL regexp_split_to_table(composer, '\\s*(,|&|/)\\s*') AS x
    WHERE composer IS NOT NULL AND composer <> '' AND lower(composer) <> 'null'
) AS subquery
WHERE trimmed_name <> '' 
ON CONFLICT (name) DO NOTHING;
***/

-- Backfill track_composer junction table by mapping each track_id to the corresponding artist_id
INSERT INTO track_composer (track_id, artist_id)
SELECT t.track_id, a.artist_id
FROM track t
JOIN artist a ON lower(a.name) = lower(t.composer)
WHERE t.composer IS NOT NULL AND t.composer <> '' AND lower(t.composer) <> 'null';
