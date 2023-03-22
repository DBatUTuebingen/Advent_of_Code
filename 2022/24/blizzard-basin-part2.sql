-- AoC 2022, Day 24 (Part 2)

-- AoC input file
CREATE MACRO input() AS 'input.txt';

.read blizzard-basin.sql

-- three consecutive expeditions:
--  from start to goal,
--  return to start
--  going to goal once more
SELECT expedition(
         expedition(
           expedition(0, start(), goal()),  -- 
           goal(), start()),                -- 
         start(), goal()) AS minutes;       -- 
