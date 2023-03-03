# [Advent of Code 2022, Day 23](https://adventofcode.com/2022/day/23)

## Unstable Diffusion

I have deliberately implemented this day *without* the help of arrays.
Tiles are represented by a sparse table that only contains `(x,y)`
locations that host elves.

The recursive CTE common to both parts lives in `unstable-diffusion.sql`.

Directions and tile neighborhood are encoded using bit strings.  With
DuckDBs improved support for aggregations over type `bit` 
(see <https://github.com/duckdb/duckdb/pull/6417>), macro `byte()` 
should become obsolete.

Macro `done(p)` encodes when a row `p` of the working table indicates
that the iteration is complete:

- Part 1: # of required rounds reached (see macro `rounds()`),
- Part 2: all elf locations are stable (elves do not move).


### Part 1

Takes about 5s on my MacBook Pro (M1 Pro).

Usage:

~~~
$ duckdb < unstable-diffusion-part1.sql
┌─────────────┐
│ empty_tiles │
│    int64    │
├─────────────┤
│        4162 │
└─────────────┘
~~~


### Part 2

Takes about 6m40s on my MacBook Pro (M1 Pro).

Usage:

~~~
$ duckdb < unstable-diffusion-part2.sql
┌──────────────┐
│ no elf moved │
│    int32     │
├──────────────┤
│          986 │
└──────────────┘
~~~
