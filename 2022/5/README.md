# [Advent of Code 2022, Day 5](https://adventofcode.com/2022/day/5)

## Supply Stacks

### Part 1

Usage:

~~~
$ duckdb -no-stdin -init supply-stacks-part1.sql
-- Loading resources from supply-stacks-part1.sql
┌───────────┐
│  crates   │
│  varchar  │
├───────────┤
│ GRTSWNJHH │
└───────────┘
~~~

### Part 2

In this SQL query, do *not* reverse the list of picked up crates,
since a crane picks up more than one crate at once (i.e., FIFO, instead
of LIFO). **Everything else is just like in Part 1**.

Usage:

~~~
$ duckdb -no-stdin -init supply-stacks-part2.sql
-- Loading resources from supply-stacks-part2.sql
┌───────────┐
│  crates   │
│  varchar  │
├───────────┤
│ QLFQDBBHM │
└───────────┘
~~~
