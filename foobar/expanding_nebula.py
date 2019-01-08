def generate(c1,c2,bitlen): # in : pair of (pre) cols ; out : (post) col
    a = c1 & ~(1<<bitlen)
    b = c2 & ~(1<<bitlen)
    c = c1 >> 1
    d = c2 >> 1
    return (a&~b&~c&~d) | (~a&b&~c&~d) | (~a&~b&c&~d) | (~a&~b&~c&d)

from collections import defaultdict
def build_map(n, nums): # n = ncol = bitlen
    mapping = defaultdict(set)
    nums = set(nums)
    for i in range(1<<(n+1)): # every bit vector of length n+1
        for j in range(1<<(n+1)):
            # find post of each possible pre (col from col pair)
            generation = generate(i,j,n)
            if generation in nums:
                mapping[(generation, i)].add(j)
    return mapping

def answer(g):
    g = list(zip(*g)) # transpose
    nrows = len(g)
    ncols = len(g[0])

    # turn map into numbers
    nums = [sum([1<<i if col else 0 for i, col in enumerate(row)]) for row in g]

    # rows are now (len ncol) bit vectors

    mapping = build_map(ncols, nums)

    # mapping maps (post col) -> (pre col pair)

    preimage = {i: 1 for i in range(1<<(ncols+1))} # dictionary
    # initially 1s to be consistent with multiplicity

    for row in nums:
        next_row = defaultdict(int)
        for c1 in preimage:
            # c1 is possible (pre) row
            for c2 in mapping[(row, c1)]:
                # find all possible (pre) rows that pair with c1
                # account for multiplicity
                next_row[c2] += preimage[c1]
        preimage = next_row # move to next (post) row
    ret = sum(preimage.values()) # add up final counts

    return ret

g = [[True, True, False, True, False, True, False, True, True, False],
 [True, True, False, False, False, False, True, True, True, False],
 [True, True, False, False, False, False, False, False, False, True],
 [False, True, False, False, False, False, True, True, False, False]
]

print(answer(g))
