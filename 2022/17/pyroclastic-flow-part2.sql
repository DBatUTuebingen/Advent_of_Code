-- AoC 2022, Day 17 (Part 2)

-- # of rocks to drop
CREATE MACRO rocks()  AS 2500;
CREATE MACRO huuuge() AS 1000000000000;
-- AoC input file
CREATE MACRO input() AS 'input.txt';

-- depth of chamber (# of chamber rows until all columns are blocked)
CREATE MACRO depth(chamber) AS TABLE
  (SELECT MIN(depth)
   FROM   (SELECT  ROW_NUMBER() OVER () AS depth,
                   bit_or(r) OVER (ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS blocked
           FROM    (SELECT unnest(chamber)) AS _(r)
           QUALIFY blocked = bits('#########')) AS _);


-- simulation of pyroclastic flow (# of iterations is rocks())
.read pyroclastic-flow.sql

-- only required for some inputs:
-- more memory for LATERAL depth() evaluation
PRAGMA temp_directory = '/tmp';
PRAGMA memory_limit = '128GB';


WITH RECURSIVE
-- state of simulation (current jet pattern, next rock, chamber) for each dropped rock
simulation(shape, jet, rock, chamber) AS (
  SELECT   p.flow.shape AS shape, p.flow.jet AS jet, p.flow.rock AS rock, p.flow.chamber AS chamber
  FROM     pyroclastic AS p
  WHERE    p.flow.y = 1
),
-- optimization: disregard chamber below an entirely blocked row
blocked(shape, jet, chamber) AS (
  SELECT s.shape, s.jet, s.chamber[1:list_indexof(s.chamber, bits('#########'))] AS chamber
  FROM   simulation AS s
),
-- compute chamber height profile (top chamber rows until all columns are blocked)
profiles(shape, jet, profile) AS (
  SELECT  b.shape, b.jet, b.chamber[1:depth] AS profile
  FROM    blocked AS b,
  LATERAL depth(b.chamber) AS _(depth)
),
-- find repeating (= identical jet pattern + chamber profile) simulation states
repeats(shapes, start, "end") AS (
  SELECT list_sort(list(p.shape)) AS shapes, shapes[1] AS start, shapes[2] AS end
  FROM   profiles AS p
  GROUP BY p.jet, p.profile
  HAVING len(shapes) = 2
  LIMIT 1
),
-- details of cyclic rock drops
cycle(start, "end", length, height, rocks_missing, skip, rocks_to_drop) AS (
  SELECT r.start,                                                                  -- start/end of cycle
         r.end,
         r.end - r.start                                         AS length,        -- # of shapes dropped between start/end of cycle
         len([1 for h in s2.chamber if h > bits('#.......#')]) -
         len([1 for h in s1.chamber if h > bits('#.......#')])   AS height,        -- # of chamber rows gained during one cycle
         huuuge() - r.start                                      AS rocks_missing, -- # of rocks to drop after start of cycle
         rocks_missing / length                                  AS skip,          -- # of cycles that we can skip over
         rocks_missing % length                                  AS rocks_to_drop  -- # of rocks still left to drop after skipping
  FROM   repeats AS r, simulation AS s1, simulation AS s2
  WHERE  s1.shape = r.start AND s2.shape = r.end
)
--           height of chamber built before & after cycle
--       ┌───────────────────────────────────────────────────────┐
SELECT   len([ 1 for h in s.chamber if h > bits('#.......#')]) - 1
       + c.skip * c.height AS tower
--       └───────────────┘
--       height of chamber that would be built by running the cycle c.skip times
FROM   cycle AS c, simulation AS s
WHERE  s.shape = c.start + c.rocks_to_drop + 1;
