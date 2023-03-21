# [Advent of Code 2022, Day 24](https://adventofcode.com/2022/day/25)

## Blizzard Basin

Again, implemented without the use of arrays.  Preparatory CTE
`open(minute,xy)` precomputes the `xy` locations of all open (≡
walkable, `.`) spots at the given `minute` time step.  Since
the blizzard constellation repeats after `lcm(width, height)`
minutes, we can limit the precomputation work.

(At the time of writing, DuckDB did not implement `lcm` or `gcd`
yet, so we resort to an explicit recursive formulation.  With
Denis' PR https://github.com/duckdb/duckdb/pull/6766 this should
be rectified soon, hopefully.)

The main CTE `expedition(minute, x, y, done)` records **all possible elf
`x,y` locations at every `minute`** until `(x,y) ≡ grid.stop` (at which
point we have `done ≡ true`).  

We wrap the CTE in a macro `expedition(minute, here, there)` in file
`blizzard-basin.sql` since Part 2 needs to invoke the expedition three
times.


### Part 1


Usage:

Blizzard precomputation takes the lion share of time (~3 minutes
on my MacBook M1 Pro).  The actual expedition then finishes within 4 seconds.

~~~
$ duckdb < blizzard-basin-part1.sql
Run Time (s): real 0.000 user 0.000022 sys 0.000008
Run Time (s): real 182.341 user 706.577883 sys 40.820970 ← precomputation
Run Time (s): real 0.001 user 0.000385 sys 0.000012
┌─────────┐
│ minutes │
│  int32  │
├─────────┤
│     297 │
└─────────┘
Run Time (s): real 3.701 user 10.388853 sys 1.061041 ← expedition
~~~

### Part 2

Usage:

~~~
$ duckdb < blizzard-basin-part2.sql
Run Time (s): real 0.000 user 0.000016 sys 0.000003
Run Time (s): real 183.493 user 888.513324 sys 24.570338 ← precomputation
Run Time (s): real 0.000 user 0.000384 sys 0.000003
┌─────────┐
│ minutes │
│  int32  │
├─────────┤
│     856 │
└─────────┘
Run Time (s): real 10.728 user 30.184098 sys 3.257323 ← three expeditions
~~~