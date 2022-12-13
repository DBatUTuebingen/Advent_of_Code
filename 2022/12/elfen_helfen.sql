-- definitions for puzzle input
\i points.sql
DROP TABLE IF EXISTS heightmap;
DROP TABLE IF EXISTS input;
CREATE TABLE heightmap (row int, col int, height char(1));
CREATE TABLE input (idx SERIAL, row text);

COPY input(row) FROM '/Users/louisalambrecht/git/Advent_of_Code/2022/12/example_input.txt' DELIMITER ',' CSV;

-- todo: better with unnest rather than substring
INSERT INTO heightmap
SELECT idx AS row, col AS col, substring(row from col for 1) AS height
FROM input, generate_series(1, (SELECT length(row) FROM input LIMIT 1)) AS col;

DROP TABLE input;

CREATE OR REPLACE FUNCTION ascii2 (height char(1)) RETURNS int AS
$$
-- SELECT CASE WHEN height = 'S' THEN ascii('a') WHEN height = 'E' THEN ascii('z') ELSE ascii(height) END;
SELECT ascii('a') WHERE height = 'S'
UNION ALL
SELECT ascii('z') WHERE height = 'E'
UNION ALL
SELECT ascii(height) WHERE height <> 'S' and height <> 'E'
$$ LANGUAGE SQL;


-- Finding shortest path from 'S' to 'E' by moving up max. 1 level
WITH RECURSIVE
euclidean_distance AS (
    SELECT h.row, h.col, point(h.row,h.col) <-> point(hm.row,hm.col) AS dist
    FROM heightmap AS h, heightmap AS hm
    WHERE hm.height = 'E'
),
path_finding(row, col, height, dir, steps, dist_est, path) AS (
    SELECT h.row, h.col, h.height, NULL::char(1), 0, e.dist, ARRAY[point(h.row, h.col)]
    FROM heightmap AS h, euclidean_distance AS e
    WHERE height='S' AND h.row = e.row AND h.col = e.col

    UNION ALL

    (WITH path_findings AS (
        SELECT * FROM path_finding
    )
        -- go to the right >
        SELECT h.row, h.col, h.height, '>'::char(1), p.steps + 1, e.dist, p.path || point(h.row, h.col) AS path
        FROM path_findings p, heightmap h, euclidean_distance e
        WHERE h.height IS NOT NULL AND NOT ARRAY[point(h.row, h.col)] <@ p.path
        AND p.row = h.row AND h.row = e.row AND h.col = p.col + 1 AND h.col = e.col
        AND ascii2(h.height) <= ascii2(p.height) + 1
        AND p.height <> 'E'

        UNION ALL

        -- go to the left <
        SELECT h.row, h.col, h.height, '<'::char(1), p.steps + 1, e.dist, p.path || point(h.row, h.col) AS path
        FROM path_findings p, heightmap h, euclidean_distance e
        WHERE h.height IS NOT NULL AND NOT ARRAY[point(h.row, h.col)] <@ p.path
        AND p.row = h.row AND h.row = e.row AND h.col = p.col - 1 AND h.col = e.col
        AND ascii2(h.height) <= ascii2(p.height) + 1
        AND p.height <> 'E'

        UNION ALL

        -- go down v
        SELECT h.row, h.col, h.height, 'v'::char(1), p.steps + 1, e.dist, p.path || point(h.row, h.col) AS path
        FROM path_findings p, heightmap h, euclidean_distance e
        WHERE h.height IS NOT NULL AND NOT ARRAY[point(h.row, h.col)] <@ p.path
        AND p.row + 1 = h.row AND h.row = e.row AND h.col = p.col AND h.col = e.col
        AND ascii2(h.height) <= ascii2(p.height) + 1
        AND p.height <> 'E'

        UNION ALL

        -- go up ^
        SELECT h.row, h.col, h.height, '^'::char(1), p.steps + 1, e.dist, p.path || point(h.row, h.col) AS path
        FROM path_findings p, heightmap h, euclidean_distance e
        WHERE h.height IS NOT NULL AND NOT ARRAY[point(h.row, h.col)] <@ p.path
        AND p.row - 1 = h.row AND h.row = e.row AND h.col = p.col AND h.col = e.col
        AND ascii2(h.height) <= ascii2(p.height) + 1
        AND p.height <> 'E'
    )
)
SELECT p.*
FROM path_finding AS p
WHERE (SELECT ARRAY[point(h.row, h.col)] FROM heightmap h WHERE h.height = 'E') <@ p.path
AND p.steps = (SELECT MIN(p.steps)
FROM path_finding AS p
WHERE (SELECT ARRAY[point(h.row, h.col)] FROM heightmap h WHERE h.height = 'E') <@ p.path);

