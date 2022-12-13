-- AoC 2022, Day 1 (Part 1)

WITH
input(calories, num) AS (
  SELECT c.calories, ROW_NUMBER() OVER () AS num
  FROM   read_csv_auto('input.txt') AS c(calories)
),
reindeers(reindeer, calories) AS (
  SELECT SUM(i.calories IS NULL :: int) OVER (ORDER BY num) AS reindeer, i.calories
  FROM   input AS i
)
SELECT   SUM(r.calories) AS calories
FROM     reindeers AS r
GROUP BY r.reindeer
ORDER BY calories DESC
LIMIT 1;
