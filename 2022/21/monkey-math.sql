-- AoC 2022, Day 21 

CREATE TEMP TABLE raw ( i int PRIMARY KEY, line text NOT NULL );

INSERT INTO raw
SELECT ROW_NUMBER() OVER () AS i, line 
FROM   read_csv_auto('input.txt') AS _(line);

DROP TYPE IF EXISTS op;
CREATE TYPE op AS ENUM ('+','-','*','/');

DROP TYPE IF EXISTS kind;
CREATE TYPE kind AS ENUM ('mnky', 'root', 'humn');

CREATE TEMP TABLE input ( 
  id   int     PRIMARY KEY, 
  name char(4) NOT NULL UNIQUE,
  expr union(val int, expr text[])
);

INSERT INTO input
SELECT r.i, r.line[:4], r.line[7:] :: int
FROM   raw AS r 
WHERE  r.line ~ '^[a-z]{4}: [0-9]+$';
INSERT INTO input -- ⚠ Cannot use UNION ALL here, because of union-column `expr` (bug?)
SELECT i, name, expr
FROM (SELECT r.i, r.line[:4], string_to_array(r.line[7:],' ') AS expr
      FROM   raw AS r
      WHERE  r.line ~ '^[a-z]{4}: [a-z]{4} [+|\-|*|/] [a-z]{4}$') AS _(i,name,expr);

CREATE TEMP TABLE monkeys ( 
  id   int     PRIMARY KEY, 
  kind kind    NOT NULL,
  expr union(val  bigint, 
             expr struct (l  int, 
                          op op,
                          r  int))
);

DROP MACRO IF EXISTS to_kind;
CREATE MACRO to_kind(str) AS CASE WHEN str IN ('root','humn') THEN str ELSE 'mnky' END;

INSERT INTO monkeys 
SELECT i.id, to_kind(i.name), i.expr.val  
FROM   input AS i
WHERE  i.expr.val IS NOT NULL;
INSERT INTO monkeys  -- ⚠ Cannot use UNION ALL here, because of union-column `expr` (bug?)
SELECT i.id, to_kind(i.name), {l: l.id, x: i.expr.expr[2], r: r.id} 
FROM   input AS i JOIN 
       input AS l ON i.expr.expr[1] = l.name JOIN 
       input AS r ON i.expr.expr[3] = r.name  
WHERE  i.expr.expr IS NOT NULL;

-- Assumption: all monkeys either listen to two monkeys no one else listens to 
-- (or are screamers which listen to no one)
CREATE TEMP TABLE listeners (
  screamer int PRIMARY KEY,
  listener int
);

CREATE INDEX listener_idx ON listeners (listener);

INSERT INTO listeners
SELECT m.expr.expr.l, m.id
FROM   monkeys AS m 
WHERE  m.expr.expr IS NOT NULL
  UNION ALL 
SELECT m.expr.expr.r, m.id 
FROM   monkeys AS m 
WHERE  m.expr.expr IS NOT NULL;

-- Part 1:
WITH RECURSIVE 
eval(screamer, kind, val) AS (
  SELECT m.id, m.kind, m.expr.val
  FROM   monkeys AS m 
  WHERE  NOT m.expr.val IS NULL
    UNION ALL 
  SELECT CASE 
           WHEN n.id_l IS NULL THEN n.id_r 
           WHEN n.id_r IS NULL THEN n.id_l 
           ELSE n.id 
         END,
         CASE 
           WHEN n.kind_l IS NULL THEN n.kind_r 
           WHEN n.kind_r IS NULL THEN n.kind_l 
           ELSE n.kind 
         END,
         CASE 
           WHEN n.val_l IS NULL THEN n.val_r 
           WHEN n.val_r IS NULL THEN n.val_l
           ELSE CASE n.op
                  WHEN '+' THEN n.val_l + n.val_r
                  WHEN '-' THEN n.val_l - n.val_r
                  WHEN '*' THEN n.val_l * n.val_r
                  WHEN '/' THEN n.val_l / n.val_r
                END  
          END
  FROM    (
    SELECT DISTINCT ON (m.id)
           m.id, m.kind, m.expr.expr.op, 
           e_l.screamer, e_l.kind, e_l.val, 
           e_r.screamer, e_r.kind, e_r.val
    FROM   listeners AS l1 LEFT JOIN eval AS e_l ON l1.screamer = e_l.screamer,
           listeners AS l2 LEFT JOIN eval AS e_r ON l2.screamer = e_r.screamer JOIN 
           monkeys   AS m                        ON l2.listener = m.id
    WHERE  l1.listener = l2.listener
    AND    NOT m.expr.expr IS NULL
    AND    NOT (e_l.screamer IS NULL AND e_r.screamer iS NULL)
    AND    (   e_l.screamer IS NULL 
            OR e_r.screamer IS NULL 
            OR m.expr.expr.l = e_l.screamer AND m.expr.expr.r = e_r.screamer)
  ) AS n(id, kind, op, id_l, kind_l, val_l, id_r, kind_r, val_r)
  WHERE   NOT EXISTS (SELECT 1 FROM eval AS e WHERE e.kind = 'root')
)
SELECT e.val AS "Day 21 (part 1)"
FROM   eval AS e
WHERE  e.kind = 'root';