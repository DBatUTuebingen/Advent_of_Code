# [Advent of Code 2022, Day 9](https://adventofcode.com/2022/day/9)

## Rope Bridge

### Part 1

This runs in about 226 seconds on Torsten's MacBook Pro (M1 Pro).
Since `input.txt` contains 2000 rows (= head movements) only, this
is surprisingly slow.  **TODO:** make sure that the `CREATE MACRO`
isn't the culprit here.

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

**TODO**

Idea: Since

- knot 1 (in Part 1: tail `T`) follows head `H`,
- knot 2 follows knot 1,
- knot 3 follows knot 2,
- ...
- knot 9 (the tail) follows knot 8,

run the recursive CTE `T` nine times, each time
consuming the output of its former run (or the output
of `H` for the first run).  This should run in
about 9 × 226 seconds ≈ 34 minutes.


