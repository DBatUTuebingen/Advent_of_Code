-- AoC 2022, Day 23 (Part 2)

-- AoC input file
CREATE MACRO input() AS 'input.txt';

-- done once all elf locations are stable
CREATE MACRO done(p) AS p."stable?";

.read unstable-diffusion.sql

SELECT DISTINCT r.round AS "no elf moved"
FROM   rounds AS r
WHERE  r."stable?";
