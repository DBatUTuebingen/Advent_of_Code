-- definitions for puzzle input
DROP TABLE IF EXISTS heightmap;
DROP TABLE IF EXISTS input;
DROP TABLE IF EXISTS distance_estimation;
DROP SEQUENCE IF EXISTS serial;
CREATE TEMP SEQUENCE serial minvalue 0 start 0;

-- macro to treat 'S' as 'a' and 'E' as 'z'
-- do NOT use union here if the macro is used in the CTE
CREATE MACRO ascii2(height) AS
CASE WHEN height = 'S' THEN ascii('a')
     WHEN height = 'E' THEN ascii('z')
     ELSE ascii(height) END;

-- read input
WITH RECURSIVE input(row, map) AS (
     SELECT ROW_NUMBER() OVER () AS row, string_to_array(s, '') AS map
     FROM read_csv_auto('/Users/louisalambrecht/git/Advent_of_Code/2022/12/input.txt') AS c(s)
),
-- parse input into desired format
-- todo: find out whether unnest and sequence always produce the correct assignment
heightmap(row, col, height) AS (
     SELECT i.row AS row,
            generate_subscripts(i.map, 1) AS a,
            i.map[a] AS height
     FROM input AS i
),
-- heuristik: Manhatten Distanz: sehr schlecht
-- heuristik: 3D euklidische Distanz: schlecht
-- heuristik: Manhatten Distanz + Höhenunterschied: Ok
-- heuristik: Manhatten Distanz + Höhenunterschied + euklidische Distanz: gut
heightmap_dist(row, col, height, dist) AS (
     SELECT h.row, h.col, h.height, ascii2('E') - ascii2(h.height) + ABS(hm.row-h.row) + ABS(hm.col-h.col) + sqrt((ascii2('E') - ascii2(h.height))^2 + (hm.row-h.row)^2 + (hm.col-h.col)^2) AS dist
     FROM heightmap AS h, heightmap AS hm
     WHERE hm.height = 'E'
),
-- Denis' optimierte Breitensuche
path_finding(row, col, height, steps, visited) AS (
  SELECT h.row, h.col, h.height, 0, ARRAY[ARRAY[h.row, h.col]]
  FROM heightmap AS h
  WHERE height='S'

    UNION ALL

  (WITH vis AS (SELECT DISTINCT unnest(visited) AS p FROM path_finding)
  SELECT DISTINCT ON (h.row, h.col, h.height, p.steps) h.row, h.col, h.height, p.steps + 1, array_append(p.visited, ARRAY[h.row, h.col])
  FROM   path_finding AS p, heightmap AS h
  WHERE  h.height IS NOT NULL AND NOT array_contains(p.visited, ARRAY[h.row, h.col])
  AND    (p.row = h.row AND h.col = p.col + 1
  OR     p.row = h.row+1 AND h.col = p.col
  OR     p.row = h.row-1 AND h.col = p.col
  OR     p.row = h.row AND h.col = p.col -1)
  AND    ascii2(h.height) <= ascii2(p.height) + 1
  AND    p.height <> 'E'
  AND    ARRAY[h.row,h.col] NOT IN (SELECT * FROM vis)
  )
)
SELECT * FROM path_finding WHERE height = 'E'
LIMIT 1;

-- -- A*: Finding shortest path from 'S' to 'E' by moving up max. 1 level
-- path_finding(level, row, col, height, steps, dist_est, path, explored, rank) AS (
--     SELECT 1, h.row, h.col, h.height, 0, h.dist, ARRAY[ARRAY[h.row, h.col]], false, 1
--     FROM heightmap_dist AS h
--     WHERE height='S'

--     UNION ALL

--     SELECT p.level + 1, h.row, h.col, h.height,
--     p.steps + CASE WHEN p.explored OR p.rank <> 1 OR (d.row = 0 AND d.col = 0) THEN 0 ELSE 1 END AS steps,
--     p.steps + h.dist + CASE WHEN p.explored OR p.rank <> 1 OR (d.row = 0 AND d.col = 0) THEN 0 ELSE 1 END AS dist,
--     CASE WHEN p.explored OR p.rank <> 1 OR (d.row = 0 AND d.col = 0) THEN p.path ELSE array_append(p.path, ARRAY[h.row, h.col]) END AS path,
--     CASE WHEN p.explored OR (p.rank = 1 AND d.row = 0 AND d.col = 0) THEN true ELSE false END AS explored,
--     CASE WHEN p.explored OR (p.rank = 1 AND d.row = 0 AND d.col = 0) THEN NULL
--          ELSE ROW_NUMBER() OVER (PARTITION BY CASE WHEN p.explored OR (p.rank = 1 AND d.row = 0 AND d.col = 0) THEN true ELSE false END
--                                  ORDER BY p.steps + h.dist + CASE WHEN p.explored OR p.rank <> 1 OR (d.row = 0 AND d.col = 0) THEN 0 ELSE 1 END) END AS rank
--     FROM (VALUES (-1, 0), (1, 0), (0,1), (0,-1), (0,0)) AS d(row, col)
--     JOIN path_finding p ON true
--     JOIN heightmap_dist h ON p.row + d.row = h.row  AND p.col + d.col = h.col
--     WHERE h.height IS NOT NULL
--     AND (p.rank = 1 OR (d.row = 0 AND d.col = 0))
--     AND (NOT array_contains(p.path, ARRAY[h.row, h.col]) OR p.explored OR (d.row = 0 AND d.col = 0))
--     AND ascii2(h.height) <= ascii2(p.height) + 1
--     AND p.height <> 'E'
--     AND NOT EXISTS (SELECT 1 FROM path_finding p WHERE p.height = 'E')
-- )
-- SELECT p.level, p.height, p.steps
-- FROM path_finding AS p
-- WHERE array_contains(p.path, (SELECT ARRAY[h.row, h.col] FROM heightmap h WHERE h.height = 'E'))
-- AND p.steps = (SELECT MIN(p.steps)
--                FROM path_finding AS p
--                WHERE array_contains(p.path,
--                                    (SELECT ARRAY[h.row, h.col]
--                                     FROM heightmap h
--                                     WHERE h.height = 'E')));

-- -- Breitensuche
-- path_finding(level, row, col, height, steps, path) AS (
--     SELECT 1, h.row, h.col, h.height, 0, ARRAY[ARRAY[h.row, h.col]]
--     FROM heightmap_dist AS h
--     WHERE height='S'

--     UNION ALL

--     SELECT p.level + 1, h.row, h.col, h.height, p.steps + 1, array_append(p.path, ARRAY[h.row, h.col])
--     FROM (VALUES (-1, 0), (1, 0), (0,1), (0,-1)) AS d(row, col)
--     JOIN path_finding p ON true
--     JOIN heightmap_dist h ON p.row + d.row = h.row  AND p.col + d.col = h.col
--     WHERE h.height IS NOT NULL
--     AND NOT array_contains(p.path, ARRAY[h.row, h.col])
--     AND ascii2(h.height) <= ascii2(p.height) + 1
--     AND p.height <> 'E' AND NOT EXISTS (SELECT 1 FROM path_finding p WHERE p.height = 'E')
-- )
-- SELECT DISTINCT p.level, p.height, p.steps
-- FROM path_finding AS p
-- WHERE array_contains(p.path, (SELECT ARRAY[h.row, h.col] FROM heightmap h WHERE h.height = 'E'))
-- AND p.steps = (SELECT MIN(p.steps)
--                FROM path_finding AS p
--                WHERE array_contains(p.path,
--                                    (SELECT ARRAY[h.row, h.col]
--                                     FROM heightmap h
--                                     WHERE h.height = 'E')));