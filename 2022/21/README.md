# [Advent of Code 2022, Day 21](https://adventofcode.com/2022/day/21)

## Monkey Math

### Part 1

Most of the `CASE-WHEN`-statements can be avoided, once DuckDB 
supports `UNION ALL` inside recursive queries.

Usage:

~~~
$ duckdb -no-stdin -init monkey-math.sql
-- Loading resources from monkey-math.sql
┌─────────────────┐
│ Day 21 (part 1) │
│      int64      │
├─────────────────┤
│ 276156919469632 │
└─────────────────┘
~~~

