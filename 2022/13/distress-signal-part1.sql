INSTALL json;
LOAD json;

-- read csv
WITH RECURSIVE input(row, signal) AS (
     SELECT ROW_NUMBER() OVER () AS row, s AS signal
     FROM read_csv('/Users/louisalambrecht/git/Advent_of_Code/2022/13/input-sample2.txt',
                   delim='|', header=False, columns={'signal': 'json'}) AS c(s)
),
-- parse input
data(index, first, second) AS (
    SELECT b.idx AS index, ANY_VALUE(b.first) AS first, ANY_VALUE(b.second) AS second
    FROM (
        SELECT i.row / 3 + 1 AS idx,
                ROW_NUMBER() OVER (PARTITION BY idx ORDER BY i.row) AS packet,
                CASE WHEN packet = 1 THEN i.signal ELSE NULL END AS first,
                CASE WHEN packet = 2 THEN i.signal ELSE NULL END AS second
        FROM input i
        WHERE i.signal IS NOT NULL
        ) AS b
    GROUP BY b.idx
),
-- works until here --

-- json Vergleiche sind ziemlich kaputt -> diese base cases sollte nicht so kompliziert sein
-- w.first = to_json([]) OR (w.first <= w.second AND w.second <> to_json([]))     WHERE json_array_length(w.first) = 0 and json_array_length(w.second) = 0
-- w.first = to_json([]) OR (w.first <= json_extract(w.second, '$[0]'))           WHERE json_array_length(w.first) = 0 and json_array_length(w.second) <> 0 AND json_array_length(json_extract(w.second, '$[0]')) = 0

-- first experiments!
worker (level, first, second, wf, sf, c) AS (
    SELECT 1 as level, d.first, d.second, d.first as wf, d.second as sf, NULL
    FROM data d

    UNION ALL

    SELECT w.level + 1, w.first, w.second, w.wf, w.sf, FALSE
    FROM worker w
    WHERE json_array_length(w.first) = 1 AND  json_array_length(w.second) = 0 AND w.second = to_json([])
    AND w.level < 2
)
SELECT w.level, w.first, w.second, w.c FROM worker as w;

-- SELECT d.first, d.second, d.first <= d.second
-- FROM data d;
-- WHERE d.index = 6;

-- SELECT d.index, json_extract(d.first, '$[0]') as f, json_extract(d.second, '$[0]') as g, f<=g as 'f<=g?',
-- json_array_length(f) AS 'len(f)', json_array_length(g) AS 'len(g)'
-- FROM data d;