-- AoC 2022, Day 17 (Part 1)

-- # of rocks to drop
CREATE MACRO rocks() AS 2022;
-- AoC input file
CREATE MACRO input() AS 'input.txt';

-- simulation of pyroclastic flow (# of iterations is rocks())
.read pyroclastic-flow.sql

-- height of tower in chamber
SELECT len([1 for r in p.flow.chamber if r > bits('#.......#')]) - 1 AS tower
FROM   pyroclastic AS p
WHERE  p.flow.shape > rocks();

-- debugging (chamber output)
--
-- SELECT  p.flow.shape, p.flow.jet, c AS chamber
-- FROM    pyroclastic AS p,
-- LATERAL (FROM draw(p.flow.chamber)) AS _(c);
