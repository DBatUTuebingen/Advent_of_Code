-- AoC 2022, Day 21 

CREATE TABLE raw ( i int PRIMARY KEY, line text NOT NULL );

INSERT INTO raw
SELECT ROW_NUMBER() OVER () AS i, line 
FROM   read_csv_auto('input.txt') AS _(line);

-- Holds exactly one row that describes the dimensions of the valley.
-- (1,1) to (x,y)
CREATE TABLE dimensions ( x int, y int, lcm int );

-- Least common multiple
CREATE MACRO lcm(a,b) AS (
  WITH RECURSIVE 
  gcd(curr,next) AS (
    SELECT a, b
      UNION ALL 
    SELECT gcd.next, gcd.curr % gcd.next
    FROM   gcd
    WHERE  gcd.next <> 0
  )
  SELECT a*b/gcd.curr
  FROM   gcd 
  WHERE  gcd.next = 0
);

INSERT INTO dimensions 
SELECT MAX(r.i-2), MAX(length(r.line)-2), lcm((SELECT MAX(r.i-2) FROM raw AS r),(SELECT MAX(length(r.line)-2) FROM raw AS r))
FROM   raw AS r;

CREATE TYPE dir AS ENUM ('<','^','>','v');

CREATE TABLE blizzards ( step int, dir dir, x int, y int );

CREATE INDEX pos_idx ON blizzards (step,x,y);

INSERT INTO blizzards
WITH RECURSIVE 
steps(step,dir,x,y) AS (
  SELECT  1, arr[x] :: dir, x-1, r.i-1
  FROM    raw AS r,
  LATERAL (SELECT string_to_array(r.line, '')) AS _(arr),
  LATERAL (SELECT generate_subscripts(arr,1))  AS __(x)
  WHERE   arr[x] IN ('<','^','>','v')
    UNION ALL 
  SELECT s.step+1, 
         s.dir, 
         CASE s.dir 
            WHEN '<' THEN 
              CASE WHEN s.x = 1 THEN d.x ELSE s.x-1 END
            WHEN '>' THEN 
              CASE WHEN s.x = d.x THEN 1 ELSE s.x+1 END
            ELSE s.x
          END,
          CASE s.dir 
            WHEN '^' THEN 
              CASE WHEN s.y = 1 THEN d.y ELSE s.y-1 END
            WHEN 'v' THEN 
              CASE WHEN s.y = d.y THEN 1 ELSE s.y+1 END
            ELSE s.y
         END 
  FROM   steps      AS s, 
         dimensions AS d 
  WHERE  s.step < d.lcm 
)
TABLE steps;

-- Shortest path from (1,0) to (x,y+1)
