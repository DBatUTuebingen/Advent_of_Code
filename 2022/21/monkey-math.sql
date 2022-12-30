-- AoC 2022, Day 21 

CREATE TEMP TABLE raw ( i int PRIMARY KEY, line text NOT NULL );

INSERT INTO raw
SELECT ROW_NUMBER() OVER () AS i, line 
FROM   read_csv_auto('simple.txt') AS _(line);

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
CREATE TEMP TABLE eval (
  monkey_id int    PRIMARY KEY REFERENCES monkeys(id),
  kind      kind   NOT NULL,
  val       bigint NOT NULL 
);


INSERT INTO eval
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
    AND    NOT (e_l.screamer IS NULL AND e_r.screamer iS NULL)
    AND    (   e_l.screamer IS NULL 
            OR e_r.screamer IS NULL 
            OR m.expr.expr.l = e_l.screamer AND m.expr.expr.r = e_r.screamer)
  ) AS n(id, kind, op, id_l, kind_l, val_l, id_r, kind_r, val_r)
  WHERE   NOT EXISTS (SELECT 1 FROM eval AS e WHERE e.kind = 'root')
)
SELECT DISTINCT * FROM eval;

-- Assumption: there is exactly one `root`
SELECT e.val AS "Day 21 (part 1)"
FROM   eval AS e 
WHERE  e.kind = 'root';

-- Part 2:
DROP TYPE IF EXISTS child;
CREATE TYPE child AS ENUM ('left', 'right');

-- Assumption: there is exactly one `humn`
CREATE TEMP TABLE path_to_human (
  step      int    PRIMARY KEY,
  monkey_id int    NOT NULL REFERENCES monkeys(id),
  child     child  NOT NULL,
  val       bigint NOT NULL
);

INSERT INTO path_to_human
WITH RECURSIVE 
traverse(step, id, child) AS (
  SELECT 1, m.id, NULL :: child
  FROM   monkeys AS m 
  WHERE  m.kind = 'humn'
    UNION ALL 
  SELECT t.step+1, 
         m.id,
         CASE 
           WHEN m.expr.expr.l == t.id THEN 'left'
                                      ELSE 'right'
         END :: child
  FROM   traverse  AS t JOIN 
         listeners AS l ON t.id = l.screamer JOIN 
         monkeys   AS m ON l.listener = m.id  
)
SELECT ROW_NUMBER() OVER (ORDER BY t.step DESC), 
       t.id, 
       t.child,
       CASE t.child 
         WHEN 'left'  THEN (SELECT e.val FROM eval AS e WHERE e.monkey_id = m.expr.expr.r)
         WHEN 'right' THEN (SELECT e.val FROM eval AS e WHERE e.monkey_id = m.expr.expr.l)
       END
FROM   traverse AS t JOIN monkeys AS m ON t.id = m.id
WHERE  NOT t.child IS NULL;

WITH RECURSIVE 
solve(step,x) AS (
  SELECT 1, p.val
  FROM   path_to_human AS p
  WHERE  p.step = 1
    UNION ALL 
  SELECT s.step+1, 
         CASE p.child 
           WHEN 'left'  THEN 
             CASE m.expr.expr.op
               WHEN '+' THEN  s.x - p.val
               WHEN '-' THEN  s.x - p.val
               WHEN '*' THEN  s.x / p.val
               WHEN '/' THEN  s.x * p.val
             END 
           WHEN 'right' THEN 
             CASE m.expr.expr.op
               WHEN '+' THEN  s.x - p.val
               WHEN '-' THEN (s.x - p.val) * -1
               WHEN '*' THEN  s.x / p.val
               WHEN '/' THEN  p.val / s.x
             END 
         END
  FROM   solve         AS s JOIN 
         path_to_human AS p ON p.step = s.step+1 JOIN 
         monkeys       AS m ON p.monkey_id = m.id
)
SELECT s.x
FROM   solve AS s
ORDER BY s.step DESC 
LIMIT 1;