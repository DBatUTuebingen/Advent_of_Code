
"""Note: my function returns -1 if the first list is bigger, 1 if the second list is bigger, 0 if they are the same (in the case of recursions this can happen,  but not on the final outer comparison)"""

###################### Python solution from the internet #########################

# using recursion this is quite neat
def compare_lists(first, second):
    # print('compare lists')
    while len(first) > 0 and len(second) > 0:
        left = first.pop(0)
        right = second.pop(0)
        # print(f"{left=}, {right=}")
        if type(left) == int and type(right) == int:
            if left < right:
                return 1
            elif left > right:
                return -1
        if type(left) == list and type(right) == list:
            sub_comparison = compare_lists(left, right)
            if sub_comparison != 0:
                return sub_comparison
        if type(left) == int and type(right) == list:
            sub_comparison = compare_lists(list([left]), right)
            if sub_comparison != 0:
                return sub_comparison
        if type(left) == list and type(right) == int:
            sub_comparison = compare_lists(left, list([right]))
            if sub_comparison != 0:
                return sub_comparison
    # print('compare lengths', f"{first=}, {second=}")
    if len(first) < len(second):
        return 1
    elif len(first) > len(second):
        return -1
    else:
        return 0

# using loops only (my solution) this is not very pretty anymore - but works
# the postgres version works somewhat similarly.
def compare_lists_loop(first, second):
    i = 0
    if len(first) > 0 and len(second) > 0:
        fst = first.pop(0)
        snd = second.pop(0)
    else:
        fst = first
        snd = second
        first = []
        second = []

    while len(first) >= 0 and len(second) >= 0:
        if type(fst) == int and type(snd) == int:
            if fst < snd:
                # print("fst<snd: return 1")
                return 1
            elif fst > snd:
                # print("fst>snd: return -1")
                return -1
            elif len(first) > 0 and len(second) > 0:
                fst = first.pop(0)
                snd = second.pop(0)
            else:
                break
        elif fst == None:
            return 1
        elif snd == None:
            return -1

        elif type(fst) == int and type(snd) == list:
            fst = list([fst])
        elif type(fst) == list and type(snd) == int:
            snd = list([snd])

        elif type(fst) == list and type(snd) == list:
            if len(fst) > 0 and len(snd) > 0:
                f = fst.pop(0)
                s = snd.pop(0)
                first.insert(0, fst)
                second.insert(0, snd)
                fst = f
                snd = s
            elif len(fst) < len(snd):
                return 1
            elif len(fst) > len(snd):
                return -1
            elif len(fst) == 0 and len(snd) == 0:
                if len(first) > 0 and len(second) > 0:
                    fst = first.pop(0)
                    snd = second.pop(0)
                else:
                    break

    if len(first) < len(second):
        return 1
    elif len(first) > len(second):
        return -1
    else:
        return 0

# this is the internet code again
def solve1(file, loop=False):
    with open(file, 'r') as f:
        lines = f.readlines()
        lines = [entry.strip() for entry in lines]

    index = 1
    indices = []
    while len(lines) > 0:
        list_a = eval(lines.pop(0))
        list_b = eval(lines.pop(0))
        if len(lines) > 0:
            lines.pop(0)

        # with just this small twirk to ease comparison of the recursive and looping solution
        if loop:
            comparison = compare_lists_loop(list_a, list_b)
        else:
            comparison = compare_lists(list_a, list_b)
        if comparison == 1:
            indices.append(index)
        index += 1
    print(indices)
    print(sum(indices))


def solve2(file):
    with open(file, 'r') as f:
        lines = f.readlines()
        lines = [entry.strip() for entry in lines]

    smaller_than_2 = 0
    smaller_than_6 = 0
    while len(lines) > 0:
        line = lines.pop(0)
        if len(line) == 0:
            continue
        list_from_file = eval(line)

        if compare_lists(deepcopy(list_from_file), [[2]]) == 1:
            smaller_than_2 += 1
        if compare_lists(deepcopy(list_from_file), [[6]]) == 1:
            smaller_than_6 += 1

    position_of_2 = smaller_than_2 + 1
    position_of_6 = smaller_than_6 + 2
    print(f"{position_of_2=}, {position_of_6=}")
    print(position_of_2 * position_of_6)


if __name__ == "__main__":
    solve1("input.txt", loop=True)
