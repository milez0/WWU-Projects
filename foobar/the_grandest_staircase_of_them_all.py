PARTIALPAIRS = []
PARTIALANS = []

def answer(n) :
    k = 2
    t = 3
    K = []
    T = []
    while t <= n :
        K.append(k)
        T.append(t)
        k += 1
        t += k
    s = 0
    S = []
    for i in range(len(K)) :
        N = n - T[i]
        s = partial(N, K[i])
        S.append(s)
    return sum(S)

def partial (n, k) :
    if k == 1 :
        return 1
    elif [n,k] in PARTIALPAIRS:
        return PARTIALANS[PARTIALPAIRS.index([n,k])]
    else :
        ret = 0
        for i in range(n//k + 1) :
            ret += partial(n-k*i,k-1)
        PARTIALPAIRS.append([n,k])
        PARTIALANS.append(ret)
        return ret

n=4
print(answer(n))
