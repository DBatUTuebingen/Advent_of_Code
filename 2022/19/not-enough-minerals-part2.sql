-- AoC 2022, Day 19 (Part 2)

-- duration of mining run
CREATE MACRO minutes() AS 32;

-- # of blueprints to consider
CREATE MACRO blueprints() AS 3;

-- (product of) # of geodes mined
CREATE MACRO AGG(m) AS PRODUCT(m.geodes) :: int;

-- perform mining for geodes
.read not-enough-minerals.sql
