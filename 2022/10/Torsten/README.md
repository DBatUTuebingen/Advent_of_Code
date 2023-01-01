# [Advent of Code 2022, Day 10](https://adventofcode.com/2022/day/10)

## Cathode-Ray Tube

### Part 1

Usage:

~~~
$ duckdb -no-stdin -init cathode-ray-tube-part1.sql
-- Loading resources from cathode-ray-tube-part1.sql
┌─────────────────┐
│ signal_strength │
│     int128      │
├─────────────────┤
│           12980 │
└─────────────────┘
~~~

### Part 2

Usage:

~~~
$ duckdb -no-stdin -init cathode-ray-tube-part2.sql
-- Loading resources from cathode-ray-tube-part2.sql
┌───────┬──────────────────────────────────────────┐
│  row  │                  pixels                  │
│ int64 │                 varchar                  │
├───────┼──────────────────────────────────────────┤
│     0 │ ###..###....##.#....####.#..#.#....###.. │
│     1 │ #..#.#..#....#.#....#....#..#.#....#..#. │
│     2 │ ###..#..#....#.#....###..#..#.#....#..#. │
│     3 │ #..#.###.....#.#....#....#..#.#....###.. │
│     4 │ #..#.#.#..#..#.#....#....#..#.#....#.... │
│     5 │ ###..#..#..##..####.#.....##..####.#.... │
│     6 │ .                                        │
└───────┴──────────────────────────────────────────┘
~~~
