# [Advent of Code 2022, Day 14](https://adventofcode.com/2022/day/14)

## Regolith Reservoir

### Part 1

We store the rock placement in an array (see field `rocks`
in the `sand(grain)` CTE so as to be able to easily add
grains of sand that (fell and then) rested.

On my MacBook Pro (CPU M1 Pro) the complete run takes about
7m30s.  

Usage:

~~~
$ duckdb --no-stdin --init regolith-reservoir-part1.sql
-- Loading resources from regolith-reservoir-part1.sql
┌────────┐
│ rested │
│ int32  │
├────────┤
│    817 │
└────────┘
~~~

