-- AoC 2022, Day 21 

CREATE TABLE raw ( i int PRIMARY KEY, line text NOT NULL );

INSERT INTO raw
SELECT ROW_NUMBER() OVER () AS i, line 
FROM   read_csv_auto('input.txt') AS _(line);

CREATE TABLE input ( 
  line int PRIMARY KEY, 
  inst int
);

INSERT INTO input 
SELECT r.i, string_to_array(r.line, ' ')[2]
FROM   raw AS r;

-- Part 1
CREATE TABLE eval (
  cycle int PRIMARY KEY,
  x     int NOT NULL
);

INSERT INTO eval
SELECT SUM(COALESCE(i.inst * 0 + 2, 1)) OVER eval     AS cycle,
       SUM(COALESCE(i.inst, 0))         OVER eval + 1 AS x    
FROM   input AS i
WINDOW eval AS (ORDER BY i.line ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW);

SELECT SUM((40 * segment + 20) * x) AS "Day 21 (part one)"
FROM (
  SELECT (e.cycle + 20) / 40, 
         (SELECT _e.x 
          FROM   eval AS _e 
          WHERE  _e.cycle = MAX(e.cycle))
  FROM   eval AS e
  GROUP BY (e.cycle + 20) / 40
) AS _(segment, x)
WHERE 40 * segment + 20 <= 220;