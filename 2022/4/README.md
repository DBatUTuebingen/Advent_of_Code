# [Advent of Code 2022, Day 4](https://adventofcode.com/2022/day/4)

## Camp Cleanup

### Part 1

Usage:

~~~
$ duckdb -no-stdin -init camp-cleanup-part1.sql
-- Loading resources from camp-cleanup-part1.sql
┌───────┐
│ pairs │
│ int64 │
├───────┤
│   573 │
└───────┘
~~~

### Part 2

File `camp-cleanup-part2.sql` additionally contains a
variant query that uses two `FILTER`ed `COUNT` aggregates
to solve Part 1 and Part 2 using single query.

Usage:

~~~
$ duckdb -no-stdin -init camp-cleanup-part2.sql
-- Loading resources from camp-cleanup-part2.sql
┌───────┐
│ pairs │
│ int64 │
├───────┤
│   867 │
└───────┘
┌───────┬───────┐
│ part1 │ part2 │
│ int64 │ int64 │
├───────┼───────┤
│   573 │   867 │
└───────┴───────┘
~~~
