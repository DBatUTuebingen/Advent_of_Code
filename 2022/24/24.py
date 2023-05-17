#!/usr/bin/env python3
def solve(start, stop, step):
    positions = set([start])

    while True:
        next_positions = set()
        for r, c in positions:
            for x, y in ((r, c), (r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1)):
                if (x, y) == stop:
                    return step
                # fmt:off
                if 0 <= x < height and 0 <= y < width \
                   and grid[x][(y - step) % width] != ">" \
                   and grid[x][(y + step) % width] != "<" \
                   and grid[(x - step) % height][y] != "v" \
                   and grid[(x + step) % height][y] != "^":
                    next_positions.add((x, y))
                # fmt:on
        positions = next_positions
        if not positions:
            print('***')
            positions.add(start)
        step += 1
        # print(step, ':', next_positions)


grid = [row[1:-1] for row in open(0).read().splitlines()[1:-1]]
height, width = len(grid), len(grid[0])
start, stop = (-1, 0), (height, width - 1)

print(s1 := solve(start, stop, 1))
print(s2 := solve(stop, start, s1))
print(solve(start, stop, s2))
# print(solve(start, stop, solve(stop, start, s1)))
