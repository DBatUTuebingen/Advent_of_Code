-- AoC 2021, Day 9 (Part 2)

-- AoC input file
DROP MACRO IF EXISTS input;
CREATE MACRO input() AS 'input.txt';

.read smoke-basin.sql

.timer on

WITH RECURSIVE
cave(y, x, height, basin) AS (
  SELECT h.*, ROW_NUMBER() OVER () AS basin
  FROM   heightmap AS h
),
flows(y, x, height, basin) AS (
  -- start flood fill from low points (Part 1) only
  SELECT c.*
  FROM   cave AS c SEMI JOIN lowpoints AS lp
         ON (c.y, c.x) = (lp.y, lp.x)
    UNION
  SELECT c.y, c.x, c.height, LEAST(f.basin, c.basin) AS basin
  FROM   flows AS f, cave AS c
  WHERE  (c.x, c.y) IN ((f.x+1, f.y),
                        (f.x-1, f.y),
                        (f.x  , f.y+1),
                        (f.x  , f.y-1))
  AND    c.height < 9
),
basins(y, x, basin) AS (
  SELECT f.y, f.x, MIN(f.basin) AS basin
  FROM   flows AS f
  GROUP BY f.y, f.x
)
SELECT PRODUCT(b.size) :: int AS sizes
FROM   (SELECT COUNT(*) AS size
        FROM   basins AS b
        GROUP BY b.basin
        ORDER BY size DESC
        LIMIT 3) AS b;
