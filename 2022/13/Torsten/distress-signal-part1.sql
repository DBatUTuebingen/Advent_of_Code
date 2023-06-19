-- AoC 2022, Day 13 (Part 1)

-- Depth-based packet encoding inspired by
-- https://gist.github.com/a-ponomarev/eadf5e4305960729cb54cfe5b461245d

DROP MACRO IF EXISTS input;
CREATE MACRO input() AS 'input.txt';

-- Part 1: no divider packets (empty table)
CREATE TABLE dividers (
  _       int,
  pair    int,
  "left?" boolean,
  packet  text
);

WITH
packets(_,pair,"left?",packet) AS (
  SELECT 1 + ROW_NUMBER() OVER () AS id, id // 2 AS pair, id % 2 = 0 AS "left?", c.packet
  FROM   read_csv_auto(input(), delim='', all_varchar=true) AS c(packet)
  WHERE  c.packet IS NOT NULL
  -- add divider packets
    UNION ALL
  TABLE dividers
),
depth(pair,"left?",pos,c,depth) AS (
  SELECT  p.pair,
          p."left?",
          ROW_NUMBER() OVER (PARTITION BY p.pair, p."left?") AS pos,
          i.c,
          SUM(([0,1,-1])[array_position(['[',']'], i.c)+1]) OVER (PARTITION BY p.pair, p."left?" ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) :: int AS depth
  FROM    packets AS p,
  LATERAL unnest(string_split(reverse(replace(p.packet,'10','A')), '')) AS i(c)
  --                          ^^^^^^^
  --                          ⚠️ try to compensate the lack of WITH ORDINALITY and the loss of string order
  --                             (this is a disgrace: DuckDB needs WITH ORDINALITY!)
),
nocomma(pair,"left?",c) AS (
  SELECT d.pair,
         d."left?",
         string_agg(CASE
                      WHEN d.c = ','        THEN chr(ord('!') + d.depth)
                      WHEN d.c IN ('[',']') THEN ''
                      ELSE d.c
                    END,
                    '') AS c
  FROM   depth AS d
  GROUP BY d.pair, d."left?"
)
SELECT SUM(l.pair) AS indices
FROM   nocomma AS l, nocomma AS r
WHERE  l.pair = r.pair
AND    l."left?" AND NOT r."left?"
AND    l.c < r.c;  -- correct ordering of left/right packets?
