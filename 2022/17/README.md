# [Advent of Code 2022, Day 17](https://adventofcode.com/2022/day/17)

## Pyroclastic Flow

### Part 1

Chamber and rocks are encoded as bit strings.  Facilitates
left/right rock movement (`<< 1`, `>> 1`), collision detection (based on `&`)
and merging stopped rocks with the chamber (based on `|`).
I have placed these bit manipulations inside several DuckDB
macros (`bits`, `push_left`, `push_right`, `collide`, `merge`, `draw`).


On my MacBook Pro (CPU M1 Pro) the complete run (2022 rocks
are dropped) takes about 15 seconds.


Usage:

~~~
$ duckdb < pyroclastic-flow-part1.sql
┌───────┐
│ tower │
│ int64 │
├───────┤
│  3209 │
└───────┘
Run Time (s): real 14.739 user 29.026095 sys 7.752630
~~~


### Part 2 (to be done)

Note: the resulting `pyroclastic` table of Part 1 should contain the
entire chamber history required to tackle this part: here,
1000000000000(!) rocks are dropped and we need to search for repeating
chamber patterns to tackle this.

