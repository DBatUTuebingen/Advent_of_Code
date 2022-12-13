-- AoC 2022, Day 2 (Part 2)

WITH input(them, score) AS (
  SELECT ord(c.column0) - ord('A') AS them,
         ord(c.column1) - ord('X') AS score
  FROM   read_csv_auto('input.txt', DELIM=' ') AS c
),
rock_paper_scissors(them, us, score) AS (
  -- us:  rock     paper  scissors      them:
  VALUES (0,0,1), (0,1,2), (0,2,0),  -- rock
         (1,0,0), (1,1,1), (1,2,2),  -- paper
         (2,0,2), (2,1,0), (2,2,1)   -- scissors
)
SELECT SUM(3 * rps.score + rps.us + 1) AS score
FROM   input AS i NATURAL JOIN rock_paper_scissors AS rps;

-- NB. Identical to Part 1, only column "us" of CTE input
--     has been renamed to "score".  The NATURAL JOIN thus
--     now picks up (them,score) as join columns and
--     everything works out just right.  Amazing.
