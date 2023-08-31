# [Advent of Code 2021, Day 9](https://adventofcode.com/2021/day/9)

## Smoke Basin

Input parsing and the common low point computation is placed
in the shared `smoke-basin.sql` file (included via `.read`) in
both parts.


### Part 1

Usage:

~~~
$ duckdb < smoke-basin-part1.sql
┌────────────┐
│ risk level │
│   int128   │
├────────────┤
│        526 │
└────────────┘
Run Time (s): real 0.000 user 0.000190 sys 0.000082
~~~

### Part 2

The recursice CTE `flows` essentially computes the connected components
of on the two-dimensional cave grid (components are separated by grid
spots of height `9`).  

Essential optimization: start the search for the connected components
only from the low points found in Part 1 (_not_ from all grid spots).
See the semi join between `cave` and `lowpoints` in _q₀_ of the recursive
CTE `flows`.


Usage:

Takes about 30s on my Mac Book Pro M2.

~~~
$ duckdb < smoke-basin-part2.sql
┌─────────┐
│  sizes  │
│  int32  │
├─────────┤
│ 1123524 │
└─────────┘
Run Time (s): real 30.636 user 23.693674 sys 6.924345
~~~

