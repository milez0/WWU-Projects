def answer(n, b) :
    L = len(n)
    N = []
    for char in n :
        N.append(int(char))
    H = [N[:]]
    while True :
        N.sort()
        R = N[:]
        R.reverse()
        S = []
        for i in range(L) :
            S.append(N[i] - R[i])
        for i in range(L) :
            while (S[i] < 0) :
                S[i] += b
                S[i+1] -= 1
        S.reverse()
        if (S in H) :
            return len(H) - H.index(S)
        H.append(S[:])
        N = S

n = "210022"
b = 3
print(answer(n,b))
