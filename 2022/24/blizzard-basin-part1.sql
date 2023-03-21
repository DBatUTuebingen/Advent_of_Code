-- AoC 2022, Day 24 (Part 1)

-- AoC input file
CREATE MACRO input() AS 'input.txt';

.read blizzard-basin.sql

-- single expedition from start to goal
SELECT expedition(0, start(), goal()) AS minutes;