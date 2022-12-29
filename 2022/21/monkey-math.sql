-- AoC 2022, Day 21 (Part 1)

CREATE TEMP TABLE raw ( i int PRIMARY KEY, line text NOT NULL );

INSERT INTO raw
SELECT ROW_NUMBER() OVER () AS i, line 
FROM   read_csv_auto('simple.txt') AS _(line);

DROP TYPE IF EXISTS op;
CREATE TYPE op AS ENUM ('+','-','*','/');

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
  root bool    NOT NULL,
  expr union(val  int, 
             expr struct (l  int, 
                          op op,
                          r  int))
);

INSERT INTO monkeys 
SELECT i.id, i.name = 'root', i.expr.val  
FROM   input AS i
WHERE  i.expr.val IS NOT NULL;
INSERT INTO monkeys  -- ⚠ Cannot use UNION ALL here, because of union-column `expr` (bug?)
SELECT i.id, i.name = 'root', {l: l.id, x: i.expr.expr[2], r: r.id} 
FROM   input AS i JOIN 
       input AS l ON i.expr.expr[1] = l.name JOIN 
       input AS r ON i.expr.expr[3] = r.name  
WHERE  i.expr.expr IS NOT NULL;