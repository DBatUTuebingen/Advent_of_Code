-- AoC 2021, Day 9 (Part 1)

-- AoC input file
DROP MACRO IF EXISTS input;
CREATE MACRO input() AS 'input.txt';

.read smoke-basin.sql

.timer on

SELECT SUM(lp.height + 1)  AS "risk level"
FROM   lowpoints AS lp;
