# [Advent of Code 2022, Day 25](https://adventofcode.com/2022/day/25)

## Full of Hot Air

### Part 1

⚠️ There is no Part 2 on Day 25.

This could have used a DuckDB `map` value to represent
the mapping from SNAFU to decimal numbers, but using
the `dec_to_snafu` CTE felt "more relational" (and also
enabled the inclusion of the convenient `carry` column).

Usage:

~~~
$ duckdb -no-stdin -init full-of-hot-air.sql
-- Loading resources from full-of-hot-air.sql
┌──────────────────────┐
│        snafu         │
│       varchar        │
├──────────────────────┤
│ 2=001=-2=--0212-22-2 │
└──────────────────────┘
~~~

