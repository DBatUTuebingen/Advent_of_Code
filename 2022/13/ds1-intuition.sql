-- the first example in "input-sample.txt" is straightforward and working. The second one (idx=2) involves
-- going up the tree and is problematic. This example doesn't make any progress from iteration 3-8 (variable i)
-- and tbh I don't understand why progress starts again in iterations 9-12. (The result of this example is correct
-- but this is not the desired behaviour, obviously.)
.nullvalue '⎕'
.maxrows 170

-- FIXME: this is hardcoded: start sequence at some number > input length
CREATE SEQUENCE serial START 1000;

-- compare two numbers
CREATE MACRO comp(fst, snd) AS (
SELECT -1 WHERE fst < snd
UNION ALL
SELECT 0 WHERE fst == snd
UNION ALL
SELECT 1 WHERE fst > snd
);

-- read csv
WITH RECURSIVE input(row, signal) AS (
     SELECT ROW_NUMBER() OVER () AS row, s AS signal
     FROM read_csv('/Users/louisalambrecht/git/Advent_of_Code/2022/13/input.txt',
                   delim='|', header=False, columns={'signal': 'char[]'}) AS c(s)
),
-- parse input into sensible schema
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
),
-- compares the corresponding lists and integers
-- this is a very unefficient implementation: it compares all corresponding items (breadth first search)
-- without cutting of early (because actually a depth first search is required)
worker(i, idx, parent, id, ids, fst, snd, rec, res) AS (
    SELECT 1, idx, idx, nextval('serial') as id, [idx] as ids, unnest(fst), unnest(snd), true AS rec, NULL::Int
    FROM data

    UNION ALL
    (
    -- both are numbers: compare the numbers
    SELECT * REPLACE(i+1 AS i, false AS rec, comp(fst::Int, snd::Int) AS res)
    FROM worker
    WHERE rec AND NOT fst ^@ '[' AND NOT snd ^@ '['

    UNION ALL

    -- fst is number, snd is list: convert the number into a list
    SELECT * REPLACE(i+1 AS i, '[' || fst || ']' AS fst)
    FROM worker
    WHERE rec AND NOT fst ^@ '[' AND snd ^@ '['

    UNION ALL

    -- fst is number, snd is list: convert the number into a list
    SELECT * REPLACE(i+1 AS i, '[' || snd || ']' AS snd)
    FROM worker
    WHERE rec AND fst ^@ '[' AND NOT snd ^@ '['

    UNION ALL

    -- both are lists: recurse with further unnesting
    SELECT * REPLACE(i+1 AS i,
                     id AS parent,                 -- remembering the tree structure - maybe we need
                     list_prepend(id, ids) AS ids, -- more sophisticated info to make tree traversal
                                                   -- in the collector easier
                     nextval('serial') AS id,
                     unnest(fst::char[]) AS fst,   -- unnest both lists and compare those
                     unnest(snd::char[]) AS snd
    )
    FROM worker
    WHERE rec AND fst ^@ '[' AND snd ^@ '['

    UNION ALL

    -- fst is null (right list is shorter---aka fst<snd)
    SELECT * REPLACE(i+1 AS i, false AS rec, -1 AS res)
    FROM worker
    WHERE rec AND fst IS NULL AND snd IS NOT NULL

    UNION ALL

    -- snd is null (left list is shorter---aka fst>snd)
    SELECT * REPLACE(i+1 AS i, false AS rec, 1 AS res)
    FROM worker
    WHERE rec AND fst IS NOT NULL AND snd IS NULL
    )
),
------------------------ everything works until here -----------------------------
-- since the worker did a bfs not caring about when to cut off, the collector now needs to traverse
-- the results of the worker in dfs manner to obtain the correct result per index/list comparison:
-- node=0: continue dfs, node=1: overall result=false, node=-1: overall result=true
collector(i, idx, parent, id, ids, fst, snd, rec, res, finished, last_iter) AS (
    -- copy the result rows of the worker + reset + two more
    SELECT * REPLACE(1 AS i, true AS rec), false AS finished, false AS last_iter
    FROM worker
    WHERE NOT rec

    UNION ALL

    (WITH lastIteration AS (
        SELECT * FROM collector WHERE last_iter
    ),
    -- identify next row to collect in dfs manner
    rank1 AS (
        -- collect result rows with min id on first iteration (the leftmost child under the root has the min id)
        SELECT * EXCLUDE(r)
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY idx ORDER BY id) AS r
            FROM collector
            WHERE rec
        )
        WHERE (SELECT COUNT(*) FROM lastIteration) = 0 AND r = 1

        UNION ALL
        -- collect result rows following tree structure on every following iteration
        (WITH RECURSIVE
        -- following the tree structure down to siblings/children
        toSiblingOrChildren AS (
            SELECT c.*
            FROM collector c, lastIteration l
            WHERE c.rec AND c.idx = l.idx AND (list_contains(c.ids, l.id+1) OR l.id + 1 = c.id)
        ), idxs(idx) AS (
            SELECT idx FROM lastIteration WHERE idx NOT in (SELECT idx FROM toSiblingOrChildren)
        )
        -- following the tree structure up (because the current subtree is explored)
        -- this is presumably the part that fails. On the other hand, I don't see much change when
        -- this part is commented out. But it should be essential to go up the tree.
        , toParent(x) AS (
            SELECT 0 AS x, NULL AS i, idx AS idx, NULL AS parent, NULL AS id, NULL AS ids, NULL AS fst, NULL AS snd, NULL AS rec, NULL AS res, NULL AS finished, NULL AS last_iter
            FROM idxs

            UNION ALL

            (
            SELECT x+1, NULL, p.idx, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
            FROM toParent p, lastIteration l
            WHERE p.idx = l.idx AND l.ids[x+1] IS NOT NULL

            UNION ALL

            SELECT x+1, c.*
            FROM collector c, lastIteration l, toParent p
            WHERE c.rec AND c.idx = l.idx AND c.idx = p.idx
            AND (l.ids[x+1]+1 = c.idx OR list_contains(c.ids, l.ids[x+1]+1)) -- fixed a +1 bug here
            AND NOT c.idx IN (SELECT idx FROM to_parent WHERE i IS NOT NULL) -- go up just to next node, not second next as well; fixed bug with "WHERE i IS NOT NULL" -> it used to always delete the result because it thought there already was one
            -- AND NOT c.idx IN (SELECT idx FROM to_sibling_or_children)       -- this should be covered anyway by the fact that to_parent is initialized with idxs which is already filtered from to_sibling_or_children
            -- AND l.ids[x+1] IS NOT NULL                                   -- this should be covered anyway by the fact that x=NULL doesn't hold anyway
            )
        )
        -- when finding the correct subtree to follow: pick the leftmost child (aka the one with the min id)
        SELECT * EXCLUDE(r)
        FROM ( SELECT *, ROW_NUMBER() OVER (PARTITION BY idx ORDER BY id) AS r
                FROM (
                    SELECT * FROM toSiblingOrChildren
                    UNION ALL
                    SELECT * EXCLUDE(x) FROM toParent WHERE i IS NOT NULL
                )
        )
        WHERE r = 1
        )
    ),
    -- result indicates recursion
    -- we remember these rows with the flag last_iter=True to know our current position in the tree.
    toRecurse AS (
        SELECT * REPLACE (false AS rec, true AS last_iter) FROM rank1 WHERE res = 0
    ),
    -- rows to finish: rows where we find -1/1 as a result. We can cut off computation here.
    toFinish AS (
        SELECT * REPLACE(false AS rec, true AS res)
        FROM rank1
        WHERE res = -1

        UNION ALL

        SELECT * REPLACE(false AS rec, false AS res)
        FROM rank1
        WHERE res = 1
    ),
    -- copy the finished rows to keep track of what we've seen and know now
    -- this might be a point where we can optimise and use the finished flag more efficiently
    -- atm all finished comparisons are copied each iteration until the last comparison finishes
    copyFinished AS (
        SELECT * FROM collector WHERE NOT rec AND NOT finished AND NOT last_iter AND (SELECT COUNT(*) FROM rank1) > 0
        UNION  ALL
        SELECT * REPLACE(true AS finished) FROM collector WHERE NOT rec AND NOT finished AND (SELECT COUNT(*) FROM rank1) = 0
    ),
    -- copy the worker results we need for further recursion, don't copy our current rows (in rank1)
    -- and all rows relating to our now finished comparisons (early cut-off)
    toCopy AS (
        SELECT * FROM collector
        WHERE rec AND id NOT IN (SELECT id FROM rank1) AND idx NOT IN (SELECT idx FROM toFinish)
    )
    -- collect all the results/copy rows etc
    SELECT * REPLACE(i+1 AS i) FROM toRecurse
    UNION ALL
    SELECT * REPLACE(i+1 AS i) FROM toFinish
    UNION ALL
    SELECT * REPLACE(i+1 AS i) FROM copyFinished
    UNION ALL
    SELECT * REPLACE(i+1 AS i) FROM toCopy
    )
)
SELECT SUM(idx), list_sort(list(idx))
FROM collector
WHERE finished and res;
