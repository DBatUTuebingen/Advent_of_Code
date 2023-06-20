-- AoC 2022, Day 13 (Part 1)

-- input file
DROP MACRO IF EXISTS input;
CREATE MACRO input() AS 'input.txt';

-- no divider packets (empty table)
CREATE TABLE dividers (
  _       int,
  pair    int,
  "left?" boolean,
  packet  text
);

-- read input, perform packet encoding, return table nocomma(pair,"left?",c)
-- once encoded, packets in c may be simply compared via <
.read distress-signal.sql

-- (sum of) indices with packet pairs in correct < order
SELECT SUM(l.pair) AS indices
FROM   nocomma AS l, nocomma AS r
WHERE  l.pair = r.pair
AND    l."left?" AND NOT r."left?"
AND    l.c < r.c;  -- correct ordering of left/right packets?
