-- AoC 2022, Day 13 (Part 2)


-- input file
DROP MACRO IF EXISTS input;
CREATE MACRO input() AS 'input.txt';

-- divider packets [[2]] and [[6]]
CREATE TABLE dividers (
  _       int,
  pair    int,
  "left?" boolean,
  packet  text
);

INSERT INTO dividers(pair,packet)
  VALUES (-2, '[[2]]'),
         (-6, '[[6]]');


-- read input, perform packet encoding, return table nocomma(pair,"left?",c)
-- once encoded, packets in c may be simply compared via <
.read distress-signal.sql

-- (product of) positions of divider packets
WITH
divs(pos) AS (
  SELECT  ROW_NUMBER() OVER (ORDER BY n.c) AS pos
  FROM    nocomma AS n
  QUALIFY n.pair IN (-2,-6) -- identify divider packets [[2]] and [[6]]
)
SELECT PRODUCT(d.pos) :: int AS "decoder key"
FROM   divs AS d;

