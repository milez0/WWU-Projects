def answer(l) :
    singles = []
    bigcount = []
    for i in range(len(l)) :
        bigcount.append(0)
    for i in range(len(l)) :
        for j in range(i+1, len(l)) :
            if l[j]%l[i]==0 :
                singles.append(j)
                bigcount[i] += 1
    count = 0
    for i in singles :
        count += bigcount[i]
    return count

l = [1,2,3,4,5,6,7,8,7,6,5,4,3,2,1,2,3,4,5,6,7,8]
print(answer(l))

