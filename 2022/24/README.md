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

### Part 1

The main CTE `expedition(minute, x, y, done)` records **all possible elf
`x,y` locations at every `minute`** until `(x,y) ≡ grid.stop` (at which
point we have `done ≡ true`).

Usage:

Blizzard precomputation takes the lion share of time (~3 minutes
on my MacBook M1 Pro).  The actual expedition then finishes within 4 seconds.

~~~
$ duckdb < blizzard-basin-part1.sql
Run Time (s): real 0.000 user 0.000043 sys 0.000006
Run Time (s): real 184.628 user 801.829298 sys 6.265771 ← precomputation
┌─────────┐
│ minutes │
│  int32  │
├─────────┤
│     297 │
└─────────┘
Run Time (s): real 3.905 user 13.306937 sys 1.047907 ← expedition
~~~

