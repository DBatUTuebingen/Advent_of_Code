# [Advent of Code 2022, Day 11](https://adventofcode.com/2022/day/11)

## Monkey in the Middle

NB. To avoid tedious parsing, I have manually converted the 
(very small) input files `input-sample.txt` and `input.txt` 
into SQL table definitions in `input-sample.sql` and
`input.sql`, respectively.  Parts 1 and 2 read these SQL files
via `.read`.  Builtin functions like `regexp_extract` could 
probably be used to build such a parsing stage.

### Part 1


Usage:

~~~
$ duckdb < monkey-in-the-middle-part1.sql
┌─────────────────┐
│ monkey_business │
│      int32      │
├─────────────────┤
│          119715 │
└─────────────────┘
Run Time (s): real 0.503 user 1.209931 sys 0.076013
~~~

### Part 2

The core of Part 2 is almost identical to Part 1.  We rely
on the [Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem) 
to compute column `crt`  (the product of the _prime_ divisors in 
input column `div`) to keep the (product of the) item worry 
levels manageable.

On my Mac Book Pro (CPU M1 Pro), the 10000 rounds are computed
within about 3.5 minutes.

Usage:

~~~
$ duckdb < monkey-in-the-middle-part2.sql
┌─────────────────┐
│ monkey_business │
│      int64      │
├─────────────────┤
│     18085004878 │
└─────────────────┘
Run Time (s): real 226.138 user 542.111930 sys 33.778691
~~~
