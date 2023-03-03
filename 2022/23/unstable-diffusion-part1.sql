-- AoC 2022, Day 23 (Part 1)

-- AoC input file
CREATE MACRO input() AS 'input.txt';

-- # of rounds in which elves move
CREATE MACRO rounds() AS 10;

-- done once we have moved the required # of rounds
CREATE MACRO done(p) AS p.round >= rounds();

.read unstable-diffusion.sql

--                  width                             height               elf tiles
--     ┌─────────────────────────────┐   ┌─────────────────────────────┐   ┌──────┐
SELECT (MAX(r.xy.x) - MIN(r.xy.x) + 1) * (MAX(r.xy.y) - MIN(r.xy.y) + 1) - COUNT(*) AS empty_tiles
FROM   rounds AS r
WHERE  r.round = rounds();
