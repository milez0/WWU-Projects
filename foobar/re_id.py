def answer(n) :
    primes =  [2]
    length = 1
    j = 3
    delete = False
    while(length < n+5) :
        primes.insert(0,j)
        for p in primes[1:] :
            if (j % p == 0) :
                delete = True
                break
        if (delete) :
            del primes[0]
            delete = False
        else :
            length+=len(str(j))
        j+=1
    lenadj = length - n
    ret = ""
    i = 0
    while (len(ret) < lenadj) :
        ret = str(primes[i]) + ret
        i+=1
    return ret[len(ret) - lenadj:len(ret) - lenadj + 5]

x = 10000
print(answer(x))
