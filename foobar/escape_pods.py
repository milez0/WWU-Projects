def answer(entrances, exits, path):
    entrances = set(entrances)
    exits = set(exits)
    npath = [i[:] for i in path[:]]
    entr = [0 for i in npath]
    exr = entr[:]
    rms = len(npath)
    for i in range(rms) :
        if i in entrances :
            for j in range(rms) :
                entr[j] += npath[i][j]
        if i in exits :
            for j in range(rms) :
                exr[j] += npath[j][i]
    io = 0
    for i in entrances :
        for o in exits :
            io += npath[i][o]
    bump = 0
    for i in range(rms) :
        if i in entrances or i in exits :
            del npath[i-bump]
            del entr[i-bump]
            del exr[i-bump]
            bump += 1
    rmsr = rms-bump
    bump = 0
    for i in range(rms) :
        if i in entrances or i in exits :
            for j in npath :
                del j[i-bump]
            bump += 1
    for i in range(len(npath)) :
        npath[i] = [0] + npath[i] + [exr[i]]
    entr = [0] + entr + [io]
    npath = [entr] + npath + [[0 for i in entr]]
    adj = []
    for i in range(len(npath)) :
        adj.append([])
        for j in range(len(npath[i])) :
            if npath[i][j] != 0 :
                adj[i].append(j)
    return maxflow(npath, adj)

def maxflow(path, adj) :
    rooms = len(path)
    flow = 0
    gflow = [[0 for i in range(rooms)] for j in range(rooms)]
    while True :
        q = []
        q.append(0)
        pred = [-1 for i in range(rooms)]
        M = [0 for i in range(rooms)]
        M[0] = 2000001000
        pflow, pred = bfsearch(path,adj,gflow,q,pred,M)
        if pflow == 0  :
            break
        flow += pflow
        v = -1
        while v != 0 :
            cur = pred[v]
            gflow[cur][v] = gflow[cur][v] + pflow
            gflow[v][cur] = gflow[v][cur] - pflow
            v = cur
        if pred[-1] < 0 :
            break
    return flow

def bfsearch(path, adj, gflow, q, pred, M) :
    while len(q) > 0 :
            cur = q.pop(0)
            #for v in adj[cur] :
            for v in range(len(path)) :
                if path[cur][v] - gflow[cur][v] > 0 and pred[v] == -1 :
                    pred[v] = cur
                    M[v] = min(M[cur], path[cur][v]-gflow[cur][v])
                    if v != len(path)-1 :
                        q.append(v)
                    else :
                        return M[v], pred
    return 0, pred

en = [0,1,2,3]
ex = [4]
p = [[0,4,5,0,0],
     [0,0,0,0,3],
     [0,0,0,0,2],
     [0,0,0,0,0],
     [0,0,0,0,0]]
print(answer(en,ex,p))
