# [Advent of Code 2022, Day 19](https://adventofcode.com/2022/day/19)

## Not Enough Minerals

**NB:** 

- Parts 1 and 2 share common definitions and the core SQL CTE
  found in `not-enough-minerals.sql` that runs the geodes mining
  simulation. Included in both parts via `.read`.

- Both parts benefit from materializing the inner (non-recursive) CTE
  `state`. As of today (May 20, 2023) support for the `MATERIALIZED` CTE
  modifier has not been integrated into DuckDB yet—but is expected to
  land soon.

    In the absence of support for CTE materialization, remove the
    `MATERIALIZED` modifier in `not-enough-minerals.sql`—the queries
    will work but run significantly longer (e.g., Part 1: 108 seconds
    instead of 6.2 seconds).

- The recursive CTE uses `UNION ALL` to combine multiple references to inner
  CTE `state` and thus to the working table (all `UNION ALL` branches
  are mutually exclusive, the predicate `p0` through `p4`).  Support for
  `UNION ALL` in the iterated query has been added by https://github.com/duckdb/duckdb/pull/6789
  and is included in DuckDB since release 0.8.0 (May 2023).
  
- Timings measured on my MacBook Pro (CPU M1 Pro).

### Part 1

Usage:

~~~
$ duckdb < not-enough-minerals-part1.sql
┌────────┐
│ geodes │
│ int128 │
├────────┤
│    851 │
└────────┘
Run Time (s): real 6.389 user 14.243267 sys 0.259390
~~~


### Part 2

Usage:

~~~
$ duckdb < not-enough-minerals-part2.sql
┌────────┐
│ geodes │
│ int32  │
├────────┤
│  12160 │
└────────┘
Run Time (s): real 102.257 user 126.355301 sys 1.393187
~~~

---

SQL formulation inspired by [Ruby code](https://michalmlozniak.com/notes/advent-of-code-2022-day-19-not-enough-minerals.html).

