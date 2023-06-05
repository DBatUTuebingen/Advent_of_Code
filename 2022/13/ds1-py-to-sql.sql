
-- read csv
WITH RECURSIVE input(row, signal) AS (
     SELECT ROW_NUMBER() OVER () AS row, s AS signal
     FROM read_csv('/Users/louisalambrecht/git/Advent_of_Code/2022/13/input-sample.txt',
                   delim='|', header=False, columns={'signal': 'char[]'}) AS c(s)
),
-- parse input
data(idx, fst, snd) AS (
    SELECT b.idx AS idx, ANY_VALUE(b.fst) AS fst, ANY_VALUE(b.snd) AS snd
    FROM (
        SELECT i.row // 3 + 1 AS idx,
                ROW_NUMBER() OVER (PARTITION BY idx ORDER BY i.row) AS packet,
                CASE WHEN packet = 1 THEN i.signal ELSE NULL END AS fst,
                CASE WHEN packet = 2 THEN i.signal ELSE NULL END AS snd
        FROM input i
        WHERE i.signal IS NOT NULL
        ) AS b
    GROUP BY b.idx
)
table data;

-- Fixme: transport the python solution here.