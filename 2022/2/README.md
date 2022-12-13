# [Advent of Code 2022, Day 2](https://adventofcode.com/2022/day/2)

## Rock Paper Scissors

### Part 1

Usage:

~~~
$ duckdb -no-stdin -init rock-paper-scissors-part1.sql
-- Loading resources from rock-paper-scissors-part1.sql
┌────────┐
│ score  │
│ int128 │
├────────┤
│  10624 │
└────────┘
~~~

### Part 2

The SQL query is **identical** to Part 1, only column `us` of CTE
`input` has been renamed to `score`.  The `NATURAL JOIN` thus now picks
up `(them,score)`` as join columns and everything works out just right.
*Amazing.*

Usage:

~~~
$ duckdb -no-stdin -init rock-paper-scissors-part2.sql
-- Loading resources from rock-paper-scissors-part2.sql
┌────────┐
│ score  │
│ int128 │
├────────┤
│  14060 │
└────────┘
~~~
