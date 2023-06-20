# [Advent of Code 2022, Day 13](https://adventofcode.com/2022/day/13)

## Distress Signal

**NB:** Parts 1 and 2 share a common SQL CTE found in `distress-signal.sql` 
that performs a depth-based packet encoding  Included in both parts
via `.read`.

The packet encoding is inspired and adapted from the JavaScript code found at
https://gist.github.com/a-ponomarev/eadf5e4305960729cb54cfe5b461245d.  The encoding
works in two steps:

1. Replace integer `10` by single-character symbol `A`. 
2. Scan packet string character-by-character left-to-right. Perform
   replacements:
     - `'['` → `''`
     - `']'` → `''`
     - `','` → `'!'` + _d_ (where _d_ is the current depth of `[]` bracketing)
     - _c_ → _c_ (any other character _c_)

The commonc SQL CTE `nocomma` contains column `c` in which packets are encoded
as shown above.  Once encoded, string comparison via `<` and the AoC Day 13
packet comparison coincide: _p₁_ < _p₂_ ⇔ encode(_p₁_) `<` encode(_p₂_).

We track bracket `[]` nesting depth using an old APL idiom (see _Advanced SQL_,
Chapter 5).  The scan `+\` below turns into a window-based `SUM` scan in SQL,
see CTE `depth`:

~~~plain
        xs ← '((b*2)-4×a×c)*0.5'
        +\ (1 ¯1 0)['()'⍳xs]
  1 2 2 2 2 1 1 1 1 1 1 1 0 0 0 0 0
~~~

⚠️ No recursive CTE involved at all.

On my MacBook Pro (CPU M1 Pro) both parts complete in about 20ms.


### Part 1

Usage:

~~~
$  duckdb < distress-signal-part1.sql
Run Time (s): real 0.021 user 0.038469 sys 0.007906
┌─────────┐
│ indices │
│ int128  │
├─────────┤
│    4821 │
└─────────┘
Run Time (s): real 0.001 user 0.000856 sys 0.000287
~~~


### Part 2

Usage:

~~~
$ duckdb < distress-signal-part2.sql
Run Time (s): real 0.019 user 0.036499 sys 0.006101
┌─────────────┐
│ decoder key │
│    int32    │
├─────────────┤
│       21890 │
└─────────────┘
Run Time (s): real 0.001 user 0.001186 sys 0.000705
~~~

