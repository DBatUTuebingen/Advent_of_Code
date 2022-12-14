-- definitions for puzzle input
DROP TABLE IF EXISTS heightmap;
DROP TABLE IF EXISTS input;
DROP SEQUENCE IF EXISTS serial;
CREATE TABLE input (idx int, row text[]);
CREATE TABLE heightmap (row int, col int, height char(1));
CREATE TABLE distance_estimation(row int, col int, dist int);
CREATE TEMP SEQUENCE serial minvalue 0 start 0;

-- macro to treat 'S' as 'a' and 'E' as 'z'
-- do NOT use union here if the macro is used in the CTE
CREATE MACRO ascii2(height) AS
CASE WHEN height = 'S' THEN ascii('a')
     WHEN height = 'E' THEN ascii('z')
     ELSE ascii(height) END;

-- read input
INSERT INTO input
SELECT ROW_NUMBER() OVER () AS idx, string_to_array(s, '') AS row
FROM read_csv_auto('/Users/louisalambrecht/git/Advent_of_Code/2022/12/input-sample.txt') AS c(s);

-- parse input into desired format
-- todo: find out whether unnest and sequence always produce the correct assignment
INSERT INTO heightmap
SELECT i.idx AS row
     , nextval('serial') % (SELECT len(i.row) FROM input i LIMIT 1) + 1 AS col
     , unnest(i.row) AS val
  FROM input AS i;

-- heuristic for A*: combination of manhatten distance and height distance
INSERT INTO distance_estimation
SELECT h.row, h.col, GREATEST(ascii2('E') - ascii2(h.height), ABS(hm.row-h.row) + ABS(hm.col-h.col)) AS dist
FROM heightmap AS h, heightmap AS hm
WHERE hm.height = 'E';

-- Finding shortest path from 'S' to 'E' by moving up max. 1 level
WITH RECURSIVE path_finding(row, col, height, dir, steps, dist_est, path) AS (
    SELECT h.row, h.col, h.height, NULL::char(1), 0, e.dist, ARRAY[ARRAY[h.row, h.col]]
    FROM heightmap AS h, distance_estimation AS e
    WHERE height='S' AND h.row = e.row AND h.col = e.col

    UNION ALL

    -- todo: duckdb can't use more than UNION in recursive CTEs!1elf!!
    SELECT h.row, h.col, h.height, '>'::char(1), p.steps + 1, e.dist, array_append(p.path, ARRAY[h.row, h.col])
    FROM path_finding p, heightmap h, distance_estimation e
    WHERE h.height IS NOT NULL AND NOT array_contains(p.path, ARRAY[h.row, h.col])
    AND p.row = h.row AND h.row = e.row AND h.col = p.col + 1 AND h.col = e.col
    AND ascii2(h.height) <= ascii2(p.height) + 1
    AND p.height <> 'E'
)
SELECT * FROM path_finding;



-- this is how it used to work in PostgreSQL :'(
--     UNION ALL
--         -- go to the right >
--         SELECT h.row, h.col, h.height, '>'::char(1), p.steps + 1, e.dist, p.path || point(h.row, h.col) AS path
--         FROM path_findings p, heightmap h, distance_estimation e
--         WHERE h.height IS NOT NULL AND NOT ARRAY[point(h.row, h.col)] <@ p.path
--         AND p.row = h.row AND h.row = e.row AND h.col = p.col + 1 AND h.col = e.col
--         AND ascii2(h.height) <= ascii2(p.height) + 1
--         AND p.height <> 'E'

--         UNION ALL

--         -- go to the left <
--         SELECT h.row, h.col, h.height, '<'::char(1), p.steps + 1, e.dist, p.path || point(h.row, h.col) AS path
--         FROM path_findings p, heightmap h, distance_estimation e
--         WHERE h.height IS NOT NULL AND NOT ARRAY[point(h.row, h.col)] <@ p.path
--         AND p.row = h.row AND h.row = e.row AND h.col = p.col - 1 AND h.col = e.col
--         AND ascii2(h.height) <= ascii2(p.height) + 1
--         AND p.height <> 'E'

--         UNION ALL

--         -- go down v
--         SELECT h.row, h.col, h.height, 'v'::char(1), p.steps + 1, e.dist, p.path || point(h.row, h.col) AS path
--         FROM path_findings p, heightmap h, distance_estimation e
--         WHERE h.height IS NOT NULL AND NOT ARRAY[point(h.row, h.col)] <@ p.path
--         AND p.row + 1 = h.row AND h.row = e.row AND h.col = p.col AND h.col = e.col
--         AND ascii2(h.height) <= ascii2(p.height) + 1
--         AND p.height <> 'E'

--         UNION ALL

--         -- go up ^
--         SELECT h.row, h.col, h.height, '^'::char(1), p.steps + 1, e.dist, p.path || point(h.row, h.col) AS path
--         FROM path_findings p, heightmap h, distance_estimation e
--         WHERE h.height IS NOT NULL AND NOT ARRAY[point(h.row, h.col)] <@ p.path
--         AND p.row - 1 = h.row AND h.row = e.row AND h.col = p.col AND h.col = e.col
--         AND ascii2(h.height) <= ascii2(p.height) + 1
--         AND p.height <> 'E'
--     )
-- )
-- SELECT p.*
-- FROM path_finding AS p
-- WHERE (SELECT ARRAY[point(h.row, h.col)] FROM heightmap h WHERE h.height = 'E') <@ p.path
-- AND p.steps = (SELECT MIN(p.steps)
-- FROM path_finding AS p
-- WHERE (SELECT ARRAY[point(h.row, h.col)] FROM heightmap h WHERE h.height = 'E') <@ p.path);

