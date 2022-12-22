# [Advent of Code 2022, Day 9](https://adventofcode.com/2022/day/9)

## Rope Bridge

### Part 1

This runs in about 226 seconds on Torsten's MacBook Pro (M1 Pro).
Since `input.txt` contains 2000 rows (= head movements) only, this
is surprisingly slow and appears to indicate a CTE performance
bug in DuckDB 0.6.0. 

I have thus included a variant query (see marker ⁂ in the
`rope-bridge-part1.sql`) that materializes the CTE input and runs in
about 4 seconds only.  This materializing variant is also used in Part 2.

**TODO**: 
- report the slow query as a performance bug to the DuckDB folks?


Usage:

~~~
$ duckdb -no-stdin -init rope-bridge-part1.sql
-- Loading resources from rope-bridge-part1.sql
┌─────────┐
│ visited │
│  int64  │
├─────────┤
│    5779 │
└─────────┘
Run Time (s): real 226.257 user 550.595146 sys 6.493383
~~~

### Part 2

Idea: Since

- knot 1 (in Part 1: tail `T`) follows head `H`,
- knot 2 follows knot 1,
- knot 3 follows knot 2,
- ...
- knot 9 (the tail) follows knot 8,

run the recursive CTE `T` nine times, each time consuming the output of
its former run (or the output of `H` for the first run).  This runs in
about 9 × 4 seconds. For Part1, this suggests that DuckDB performs some
unfortunate planning (in Part 1, table `H` is computed by a complex
query, in all CTEs of Part 2, `H` is a temporary materialized table).

Usage:

~~~
$ duckdb -no-stdin -init rope-bridge-part2.sql
-- Loading resources from rope-bridge-part2.sql
Run Time (s): real 0.026 user 0.046110 sys 0.001671
Run Time (s): real 4.163 user 8.938000 sys 0.451317
Run Time (s): real 3.298 user 3.435633 sys 0.142553
Run Time (s): real 3.988 user 8.351929 sys 0.663028
Run Time (s): real 3.271 user 3.419211 sys 0.122734
Run Time (s): real 5.085 user 8.284256 sys 2.145694
Run Time (s): real 4.159 user 8.423820 sys 0.851189
Run Time (s): real 4.068 user 8.469497 sys 0.706558
Run Time (s): real 4.136 user 8.501140 sys 0.771387
┌─────────┐
│ visited │
│  int64  │
├─────────┤
│    2331 │
└─────────┘
Run Time (s): real 4.094 user 8.519553 sys 0.750061
~~~
