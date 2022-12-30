# [Advent of Code 2022, Day 21](https://adventofcode.com/2022/day/21)

## Monkey Math

### Part 1

Most of the `CASE-WHEN`-statements can be avoided, once DuckDB 
supports `UNION ALL` inside recursive queries.

### Part 2

Another bug crept up, where `UNION`-columns cannot be updated,
if table has a primary key.

Usage:

~~~
$ duckdb -no-stdin -init monkey-math.sql
-- Loading resources from monkey-math.sql
┌───────────────────┐
│ Day 21 (part one) │
│       int64       │
├───────────────────┤
│   276156919469632 │
└───────────────────┘
┌───────────────────┐
│ Day 21 (part two) │
│       int64       │
├───────────────────┤
│     3441198826073 │
└───────────────────┘
~~~