# [Advent of Code 2022, Day 23](https://adventofcode.com/2022/day/23)

## Unstable Diffusion

### Part 1

I have deliberately implemented this day *without* the help of arrays.
The tiles are represented by `(x,y,elf)` where `elf` ∊ {0,1} encodes
absence/presence of an elf at location `(x,y)`.  Tile neighbourhood
is explored using the eight window frames `N`, `S`, ..., `SW`, `NE`
(with support for `EXCLUDE CURRENT ROW` in DuckDB, the number of frame
definition could be cut down, I think).

Usage:

~~~
$ duckdb < unstable-diffusion-part1.sql
┌─────────────┐
│ empty_tiles │
│    int64    │
├─────────────┤
│        4162 │
└─────────────┘
Run Time (s): real 2.668 user 7.352127 sys 0.180731
~~~

