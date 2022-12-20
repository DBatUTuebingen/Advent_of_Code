# [Advent of Code 2022, Day 6](https://adventofcode.com/2022/day/6)

## Tuning Trouble

### Part 1

The SQL contains two alternative solutions.

Usage:

~~~
$ duckdb -no-stdin -init tuning-trouble-part1.sql
-- Loading resources from tuning-trouble-part1.sql
┌────────┐
│ marker │
│ int64  │
├────────┤
│   1987 │
└────────┘
┌────────┐
│ marker │
│ int64  │
├────────┤
│   1987 │
└────────┘
~~~

### Part 2

Much like Part 1, simply extend packet (= window) size
from 4 to 14 characters.

Usage:

~~~
$ duckdb -no-stdin -init tuning-trouble-part2.sql
-- Loading resources from tuning-trouble-part2.sql
┌────────┐
│ marker │
│ int64  │
├────────┤
│   3059 │
└────────┘
~~~
