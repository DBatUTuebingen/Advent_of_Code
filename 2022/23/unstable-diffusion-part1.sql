-- AoC 2022, Day 23 (Part 1)

CREATE MACRO rounds() AS 10;

CREATE MACRO byte(bits) AS
  list_sum(list_apply(range(0,8), b -> bits[8-b] * 1 << b));

-- 2D vector
CREATE MACRO v2(x, y) AS
  {x: x, y: y};

-- 2D vector addition
CREATE MACRO addv2(v1,v2) AS
  v2(v1.x + v2.x, v1.y + v2.y);

CREATE MACRO dirs() AS
  --              N  S  W  E  NW SE SE NE
  [{bits: byte([1, 0, 0, 0, 1, 0, 0, 1]), dir: v2( 0,-1)},  -- N
   {bits: byte([0, 1, 0, 0, 0, 1, 1, 0]), dir: v2( 0, 1)},  -- S
   {bits: byte([0, 0, 1, 0, 1, 0, 1, 0]), dir: v2(-1, 0)},  -- W
   {bits: byte([0, 0, 0, 1, 0, 1, 0, 1]), dir: v2( 1, 0)}]; -- E

-- inspect vicinity, propose first direction without elves (all vicinity bits = 0)
CREATE MACRO propose(vicinity, directions) AS
  directions[list_indexof(list_apply(directions, d -> vicinity & d.bits), 0)].dir;

-- rotate array xs left
CREATE MACRO rotate(xs) AS
  xs[2:] || [xs[1]];

CREATE MACRO draw(es) AS
  list_aggr([ CASE WHEN e.elf = 0 THEN '.' ELSE '#' END for e in es ], 'string_agg', '');

.timer on

WITH RECURSIVE
input(y, row, x) AS (
  SELECT ROW_NUMBER () OVER ()      AS y,
         string_split(c.line, '')   AS row,
         generate_subscripts(row,1) AS x
  FROM   read_csv_auto('input.txt', SEP=false) AS c(line)
),
-- size (w × h tiles) of the ground
size(w, h) AS (
  SELECT MAX(i.x) AS w, MAX(i.y) AS h
  FROM   input AS i
),
-- place elves in the ground, provide for a border of non-elf (= 0)
-- tiles into which elves may move during the upcoming rounds
scan(x, y, elf) AS (
  SELECT dim.x, dim.y, COALESCE((i.row[i.x] = '#') :: int, 0) AS elf
           -- whoa, the following subquery is ugly — DuckDB's generate_series() should
           -- be converted into a table in-out function
  FROM  (  SELECT  x, y
           FROM    size AS s,
           LATERAL unnest((SELECT generate_series(0 - rounds(), s.w + rounds()))) AS  _(x),
           LATERAL unnest((SELECT generate_series(0 - rounds(), s.h + rounds()))) AS __(y)) AS dim(x,y)
         NATURAL LEFT JOIN
           input AS i
),
rounds(round, dirs, xy, elf) AS (
  SELECT 0 AS round, dirs() AS dirs, v2(s.x,s.y) AS xy, s.elf
  FROM   scan AS s

    UNION ALL

  SELECT r.round + 1 AS round,
         rotate(r.dirs) AS dirs,
         r.xy,
         -- • prop.new occurs twice {(r.xy[old], prop.new=r.xy[old]), (r.xy[new], prop.new)}:
         --   elf moves from old xy position (elf: 1→0) to new xy position (elf: 0→1)
         -- • prop.new occurs more than twice: collision (elf: no change)
         -- • prop.new occurs once:            location not involved in a move (elf: no change)
         CASE WHEN COUNT(*) OVER (PARTITION BY prop.new) = 2 THEN 1 - r.elf
              ELSE r.elf
         END AS elf
  FROM   rounds AS r,
         (SELECT  s.xy,
                  byte([COALESCE(ANY_VALUE(s.elf) OVER N , 0),
                        COALESCE(ANY_VALUE(s.elf) OVER S , 0),
                        COALESCE(ANY_VALUE(s.elf) OVER W , 0),
                        COALESCE(ANY_VALUE(s.elf) OVER E , 0),
                        COALESCE(ANY_VALUE(s.elf) OVER NW, 0),
                        COALESCE(ANY_VALUE(s.elf) OVER SE, 0),
                        COALESCE(ANY_VALUE(s.elf) OVER SW, 0),
                        COALESCE(ANY_VALUE(s.elf) OVER NE, 0)]) AS vicinity,
                  CASE WHEN s.elf AND vicinity <> 0 THEN addv2(s.xy, propose(vicinity, s.dirs))
                       ELSE s.xy
                  END AS new
          FROM    rounds AS s
          WINDOW  N   AS (PARTITION BY s.xy['x']           ORDER BY s.xy['y']           ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING),
                  S   AS (PARTITION BY s.xy['x']           ORDER BY s.xy['y']           ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING),
                  W   AS (PARTITION BY s.xy['y']           ORDER BY s.xy['x']           ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING),
                  E   AS (PARTITION BY s.xy['y']           ORDER BY s.xy['x']           ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING),
                  NW  AS (PARTITION BY s.xy['x']-s.xy['y'] ORDER BY s.xy['x']+s.xy['y'] ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING),
                  SE  AS (PARTITION BY s.xy['x']-s.xy['y'] ORDER BY s.xy['x']+s.xy['y'] ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING),
                  SW  AS (PARTITION BY s.xy['x']+s.xy['y'] ORDER BY s.xy['x']-s.xy['y'] ROWS BETWEEN 1 PRECEDING AND 1 PRECEDING),
                  NE  AS (PARTITION BY s.xy['x']+s.xy['y'] ORDER BY s.xy['x']-s.xy['y'] ROWS BETWEEN 1 FOLLOWING AND 1 FOLLOWING)) AS prop
  WHERE  r.xy = prop.xy AND r.round < rounds()
)
--                     width                                   height                  elf tiles
--     ┌───────────────────────────────────┐   ┌───────────────────────────────────┐   ┌──────┐
SELECT (MAX(r.xy['x']) - MIN(r.xy['x']) + 1) * (MAX(r.xy['y']) - MIN(r.xy['y']) + 1) - COUNT(*) AS empty_tiles
FROM   rounds AS r
WHERE  r.round = rounds()
AND    r.elf = 1;


-- debugging
--
-- SELECT r.round, draw(r.es) AS elves
-- FROM (SELECT r.round, r.xy['y'] AS y, list_sort(list({x: r.xy['x'], elf: r.elf})) AS es
--       FROM   rounds AS r
--       WHERE  r.round <= rounds()
--       GROUP BY r.round, r.xy['y']) AS r
-- ORDER BY r.round, r.y;
