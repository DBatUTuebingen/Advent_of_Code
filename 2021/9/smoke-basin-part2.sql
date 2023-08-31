-- AoC 2021, Day 9 (Part 2)

-- AoC input file
DROP MACRO IF EXISTS input;
CREATE MACRO input() AS 'input.txt';

.read smoke-basin.sql

.timer on
SET threads = 1;

WITH RECURSIVE
cave(x, y, height, basin) AS (
  SELECT h.x, h.y, h.height, ROW_NUMBER() OVER () AS basin
  FROM   heightmap AS h
),
flows(x, y, basin) AS (
  -- start flood fill from low points (Part 1) only
  SELECT c.x, c.y, c.basin
  FROM   cave AS c SEMI JOIN lowpoints AS lp
         ON (c.y, c.x) = (lp.y, lp.x)
    UNION
  SELECT c.x, c.y, LEAST(f.basin, c.basin) AS basin
  FROM   flows AS f, cave AS c
  WHERE  (c.x, c.y) IN ((f.x+1, f.y),
                        (f.x-1, f.y),
                        (f.x  , f.y+1),
                        (f.x  , f.y-1))
  AND    c.height < 9
),
basins(x, y, basin) AS (
  SELECT f.x, f.y, MIN(f.basin) AS basin
  FROM   flows AS f
  GROUP BY f.y, f.x
)
SELECT PRODUCT(b.size) :: int AS sizes
FROM   (SELECT COUNT(*) AS size
        FROM   basins AS b
        GROUP BY b.basin
        ORDER BY size DESC
        LIMIT 3) AS b;
