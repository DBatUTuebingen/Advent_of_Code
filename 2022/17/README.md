# [Advent of Code 2022, Day 17](https://adventofcode.com/2022/day/17)

## Pyroclastic Flow

**NB:** Parts 1 and 2 share a common SQL CTE found in `pyroclastic.sql` 
that runs the pyroclastic flow simulation.  Included in both parts
via `.read`.

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
Run Time (s): real 14.981 user 29.234030 sys 8.360372
┌───────┐
│ tower │
│ int64 │
├───────┤
│  3209 │
└───────┘
Run Time (s): real 0.011 user 0.005500 sys 0.004897
~~~


### Part 2

The resulting `pyroclastic` table of Part 1 contains the
entire chamber history required to tackle this part: here,
1000000000000(!) rocks are dropped and we need to search for repeating
chamber patterns to tackle this.  

The main task in Part 2 is to identify the start/end/length of this
cycle and how many rows of chamber `height` are gained during one cycle.
We use this to `skip` cycles and add `skip × height` rows to the tower
height without actually running that part of the simulation.

CTE `blocked` implements chamber cutoff, an optimization to
speed up chamber depth measurement: when are all columns in
the chamber blocked? — used for cycle detection.  For some 
inputs (e.g., `input-sample.txt`) this optimization is less
effective than for others (e.g., `input.txt`).  
`pyroclastic-flow-part2.sql` contains
~~~
PRAGMA temp_directory = '/tmp';
PRAGMA memory_limit = '128GB';
~~~
to make sure that the computation succeeds in either case.
Adapt (or comment) as required.

Usage:

~~~
$ duckdb < pyroclastic-flow-part2.sql
Run Time (s): real 18.487 user 40.222366 sys 8.717540
Run Time (s): real 0.000 user 0.000026 sys 0.000000
Run Time (s): real 0.000 user 0.000014 sys 0.000003
┌───────────────┐
│     tower     │
│     int64     │
├───────────────┤
│ 1580758017509 │
└───────────────┘
Run Time (s): real 1.532 user 4.076667 sys 0.681396
~~~

