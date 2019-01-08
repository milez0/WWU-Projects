def answer(M,F) :
    pair = [int(M),int(F)]
    pair.sort()
    count = 0
    while pair[0] != 1 :
        count += pair[1]//pair[0]
        pair[1] %= pair[0]
        if pair[1] == 0 :
            return "impossible"
        pair.sort()
    count += pair[0] + pair[1] - 2
    return count

m = 200000000
f = 100000001
print(answer(m,f))

