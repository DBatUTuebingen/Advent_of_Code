# [Advent of Code 2022, Day 7](https://adventofcode.com/2022/day/7)

## No Space Left on Device

### Part 1

Usage:

~~~
$ duckdb -no-stdin -init no-space-left-on-device-part1.sql
-- Loading resources from no-space-left-on-device-part1.sql
┌─────────┐
│  size   │
│ int128  │
├─────────┤
│ 1118405 │
└─────────┘
~~~

There is probably potential for simplification here.  See
comment in `no-space-left-on-device-part1.sql`:

Once CTE `shell` has computed its result, operate on the collected path
column (of absolute paths) directly, **DO NOT** split paths into edges
(this can save CTEs `nodes`, `edges`, `tree`?). Instead, find all
files/dirs below a dir by looking for path _prefixes_: no further
recursive CTE required.


### Part 2


Usage:

~~~
$ duckdb -no-stdin -init no-space-left-on-device-part2.sql
-- Loading resources from no-space-left-on-device-part2.sql
┌─────────────┐
│ min(s.size) │
│   int128    │
├─────────────┤
│    12545514 │
└─────────────┘
~~~
