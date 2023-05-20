-- AoC 2022, Day 19 (Part 1)

-- duration of mining run
CREATE MACRO minutes() AS 24;

-- # of blueprints to consider
CREATE MACRO blueprints() AS 30;

-- quality level of blueprint (based on # of geodes mined)
CREATE MACRO AGG(m) AS SUM(m.blueprint * m.geodes);

-- perform mining for geodes
.read not-enough-minerals.sql

