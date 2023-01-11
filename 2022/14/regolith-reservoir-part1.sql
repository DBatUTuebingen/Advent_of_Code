-- AoC 2022, Day 14 (Part 1)

-- (1) Rock parsing
CREATE TEMPORARY TABLE rocks AS
  WITH RECURSIVE
  input(path, point) AS (
    SELECT ROW_NUMBER() OVER () AS row,
           unnest(list_apply(string_split(c.line, ' -> '),
                             p -> string_split(p, ',') :: int[]))
    FROM   read_csv_auto('input.txt', SEP=false) AS c(line)
  ),
  paths(path, pos, x, y) AS (
    SELECT i.path, ROW_NUMBER() OVER (PARTITION BY i.path) AS pos,
           i.point[1] AS x, i.point[2] AS y
    FROM   input AS i
  ),
  segments("from", "to", Δ) AS (
    SELECT {x:p1.x, y:p1.y} AS from, {x:p2.x, y:p2.y} AS to,
           {x:sign(p2.x - p1.x), y:sign(p2.y - p1.y)} AS Δ
    FROM   paths AS p1, paths AS p2
    WHERE  p1.path = p2.path AND p2.pos = p1.pos + 1
  ),
  rocks("from", "to", Δ) AS (
    TABLE segments
      UNION ALL
    SELECT {x:r.from.x + r.Δ.x, y:r.from.y + r.Δ.y} AS from, r.to, r.Δ
    FROM   rocks AS r
    WHERE  r.from <> r.to
  )
  SELECT DISTINCT r.from.x, r.from.y
  FROM   rocks AS r;

-- (2) Sand simulation, sand is dropped from (x,y) = (500,0)
WITH RECURSIVE
sand(grain) AS (
  SELECT {rest:0, x:500, y:0, rocks: list({x:r.x, y:r.y})} AS grain
  FROM   rocks AS r

    UNION ALL

  SELECT CASE list_apply([{x:s.grain.x-1, y:s.grain.y+1},
                          {x:s.grain.x  , y:s.grain.y+1},
                          {x:s.grain.x+1, y:s.grain.y+1}],
                         r -> CASE WHEN list_contains(s.grain.rocks, r) THEN '#' ELSE '.' END)
           -- sand movement rules:
           --  o  →  .  |   o  →  .  |  o  →  .  |  o  →  .  |  o  →  .  |  o  →  .  |  o  →  o   (rest)
           -- ...    .o. |  ..#    .o# | .##    o## | #..    #o. | #.#    #o# | ##.    ##o | ###    ###
           WHEN ['.','.','.'] THEN {rest:s.grain.rest  , x:s.grain.x  , y:s.grain.y+1, rocks:s.grain.rocks}
           WHEN ['.','.','#'] THEN {rest:s.grain.rest  , x:s.grain.x  , y:s.grain.y+1, rocks:s.grain.rocks}
           WHEN ['.','#','.'] THEN {rest:s.grain.rest  , x:s.grain.x-1, y:s.grain.y+1, rocks:s.grain.rocks}
           WHEN ['.','#','#'] THEN {rest:s.grain.rest  , x:s.grain.x-1, y:s.grain.y+1, rocks:s.grain.rocks}
           WHEN ['#','.','.'] THEN {rest:s.grain.rest  , x:s.grain.x  , y:s.grain.y+1, rocks:s.grain.rocks}
           WHEN ['#','.','#'] THEN {rest:s.grain.rest  , x:s.grain.x  , y:s.grain.y+1, rocks:s.grain.rocks}
           WHEN ['#','#','.'] THEN {rest:s.grain.rest  , x:s.grain.x+1, y:s.grain.y+1, rocks:s.grain.rocks}
           WHEN ['#','#','#'] THEN {rest:s.grain.rest+1, x:500,         y:0          , rocks:list_prepend({x:s.grain.x, y:s.grain.y},
                                                                                                          s.grain.rocks)}
         END AS grain
  FROM   sand AS s
  WHERE  s.grain.y <= (SELECT MAX(y) FROM rocks)
)
-- Part 1
SELECT MAX(s.grain.rest) AS rested
FROM   sand AS s;

