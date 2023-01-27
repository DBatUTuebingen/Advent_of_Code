# [Advent of Code 2022, Day 20](https://adventofcode.com/2022/day/20)

## Grove Positioning System

No usage of arrays here.  Instead, all numbers in the input
are assigned a location `loc` which is used as a `ROW_NUMBER`ing
criterion that properly reorders numbers when they move.

Part 1 as well as Part 2 of this day are implemented in
file `grove-positioning-system.sql`.  Switch between both parts
by including the proper configuration file `part{1,2}.sql`
that defines

- the number of mixing rounds (`rounds()`) and
- the decryption key (`key()`).

See the `.read` directive at the top of `grove-positioning-system.sql`.


### Part 1

Single mixing round, decryption key is `1`.

Usage:

~~~
$ duckdb < grove-positioning-system.sql
┌────────┐
│ grove  │
│ int128 │
├────────┤
│   5962 │
└────────┘
Run Time (s): real 5.740 user 8.435337 sys 1.420234
~~~

### Part 2

Ten mixing rounds, decryption key is `811589153`.

Usage:

~~~
$ duckdb < grove-positioning-system.sql
┌───────────────┐
│     grove     │
│    int128     │
├───────────────┤
│ 9862431387256 │
└───────────────┘
Run Time (s): real 57.431 user 91.823269 sys 10.608113
~~~
