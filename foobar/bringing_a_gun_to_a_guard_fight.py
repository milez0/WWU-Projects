def answer(dimensions, captain_position, badguy_position, distance):
    badpairs = suicide(dimensions, captain_position, distance)
    badpairs.sort()
    bigdims = [2*d for d in dimensions]
    lims = [distance//d + 2 for d in bigdims]
    rel = [[badguy_position[i] - captain_position[i] for i in [0,1]],
           [bigdims[i]-badguy_position[i]-captain_position[i] for i in [0,1]]]
    rel.append([rel[0][0],rel[1][1]])
    rel.append([rel[1][0],rel[0][1]])
    base = []
    for i in range(lims[0]) :
        for j in range(lims[1]) :
            base.append([bigdims[0]*i,bigdims[1]*j])
            base.append([bigdims[0]*-(i+1),bigdims[1]*j])
            base.append([bigdims[0]*i,bigdims[1]*-(j+1)])
            base.append([bigdims[0]*-(i+1),bigdims[1]*-(j+1)])
    sqdist = distance**2
    bigvecs = []
    for b in base :
        for r in rel :
            v = [b[i]+r[i] for i in [0,1]]
            if v[0]**2 + v[1]**2 > sqdist :
                continue
            bigvecs.append((v[0],v[1]))
    pairvecs = []
    for t in bigvecs :
        gcd = euclidean(t)
        tup = (t[0]//gcd,t[1]//gcd)
        pairvecs.append(((tup),(t)))
    pairvecs.sort()
    vecs = []
    j = 0
    flagged = []
    for p in pairvecs :
        tup = p[0]
        t = p[1]
        while tup > badpairs[j][0] and j < len(badpairs) - 1 :
            j += 1
        if tup == badpairs[j][0] :
            flagged.append((tup, t))
        vecs.append(tup)
    toremove = flag(flagged, badpairs)
    toremove.sort()
    vecs.sort()
    i = 0
    for v in toremove :
        while v > vecs[i] and i < len(vecs) - 1 :
            i += 1
        if v == vecs[i] :
            del vecs[i]
            i -= 1
    retvecs = []
    if len(vecs) > 0 :
        retvecs.append(vecs[0])
        for v in vecs[1:] :
            if v == retvecs[-1] :
                continue
            retvecs.append(v)
    return len(retvecs)

def suicide(dimensions, pos, distance) :
    bigdims = [2*d for d in dimensions]
    rel = [[0,0], [bigdims[0]-pos[0]-pos[0], bigdims[1]-pos[1]-pos[1]],
           [0, bigdims[1]-pos[1]-pos[1]], [bigdims[0]-pos[0]-pos[0], 0]]
    base = []
    lims = [distance//d + 2 for d in bigdims]
    for i in range(lims[0]) :
        for j in range(lims[1]) :
            base.append([bigdims[0]*i,bigdims[1]*j])
            base.append([bigdims[0]*-(i+1),bigdims[1]*j])
            base.append([bigdims[0]*i,bigdims[1]*-(j+1)])
            base.append([bigdims[0]*-(i+1),bigdims[1]*-(j+1)])
    sqdist = distance**2
    pairs = []
    for b in base :
        for r in rel :
            v = [b[i]+r[i] for i in [0,1]]
            if v[0]**2 + v[1]**2 > sqdist :
                continue
            gcd = euclidean(v)
            tup = (v[0]//gcd, v[1]//gcd)
            pairs.append((tup, (v[0],v[1])))
    return pairs

def flag(flagged, badpairs) :
    bad = []
    j = 0
    for i in range(len(flagged)) :
        while flagged[i][0] > badpairs[j][0] and j < len(badpairs) - 1 :
            j += 1
        while flagged[i][0] == badpairs[j][0] :
            if badpairs[j][1][0] != 0 :
                if flagged[i][1][0]/badpairs[j][1][0] >= 1 :
                    bad.append(flagged[i][0])
                    break
            else :
                if flagged[i][1][1]/badpairs[j][1][1] >= 1 :
                    bad.append(flagged[i][0])
                    break
            if j < len(badpairs) - 1 :
                j += 1
            else :
                break
    return bad

def euclidean(Pair) :
    pair = [Pair[0],Pair[1]]
    for i in range(len(pair)) :
        if pair[i] < 0 :
            pair[i] *= -1
    pair.sort()
    if pair[1] <= 0 :
        return 1
    r = [pair[1],pair[0]]
    while r[-1] > 0 :
        r.append(r[-2]%r[-1])
    return r[-2]
"""
import cProfile
dimens = [3,2]
cap = [1,1]
bad = [2,1]
dist = 600
#cProfile.run("answer(dimens, cap, bad, dist)")
#print(answer(dimens,cap,bad,dist))
"""
print(answer([2,3],[1,1],[1,2],4))
"""
# test 1
dimens = [3,2]
cap = [1,1]
bad = [2,1]
dist = 4
print(answer(dimens, cap, bad, dist)) # 7

# test 2
dimens = [300,275]
cap = [150,150]
bad = [185,100]
dist = 500
print(answer(dimens, cap, bad, dist)) # 9

# test 3
dimens = [2,5]
cap = [1,2]
bad = [1,4]
dist = 11
print(answer(dimens, cap, bad, dist)) # 27

# test 4
dimens = [23,10]
cap = [6,4]
bad = [3,2]
dist = 23
print(answer(dimens, cap, bad, dist)) # 8

# test 5
dimens = [10,10]
cap = [4,4]
bad = [3,3]
dist = 5000
#print(answer(dimens,cap,bad,dist)) # 739323


# test 3
dimens = [5,2]
cap = [1,1]
bad = [4,1]
dist = 10
print(answer(dimens, cap, bad, dist)) # 27

dimens = [5,2]
cap = [1,1]
bad = [4,1]
dist = 4
"""
