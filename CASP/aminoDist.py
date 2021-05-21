def compareDists(subject:list, *queries:list) -> float :
    count = 0
    for query in queries :
        count += compareDist(query,subject)
    return count/len(queries)

def compareDist(subject:list, query:list) -> float :
    n = len(subject)
    if n != len(query) :
        return -float('inf')
    return sum([(subject[i]-query[i])**2 for i in range(n)])/n

def getFromFile(file) :
    n = 0
    dists = []
    this = []
    for line in file :
        if line[0:16] == "Distance between" :
            this.append(float(line.rsplit(':',1)[1]))
            n += 1
        elif n > 0 :
            dists.append(this)
            this = []
            n = 0
    return dists

files = [
    open("D:/Bork/Desktop/T0949 3X1E.txt"),
    open("D:/Bork/Desktop/T0949 4HPO.txt"),
    open("D:/Bork/Desktop/T0949 1SQB.txt"),
    open("D:/Bork/Desktop/T0950 6EK4.txt"),
    open("D:/Bork/Desktop/T0951 3W06.txt"),
    open("D:/Bork/Desktop/T0951 5CBK.txt"),
    open("D:/Bork/Desktop/T0951 5DNU.txt"),
    open("D:/Bork/Desktop/T0953s1 2GMQ.txt"),
    open("D:/Bork/Desktop/T0953s1 2VCY.txt"),
    open("D:/Bork/Desktop/T0953s1 4EBB.txt"),
    open("D:/Bork/Desktop/T0953s2 3EEH.txt"),
    open("D:/Bork/Desktop/T0953s2 3JSA.txt"),
    open("D:/Bork/Desktop/T0953s2 6CN1.txt")]

scores = []
for file in files :
    dists = getFromFile(file)
    scores.append([compareDist(dists[i],dists[20]) for i in range(20)])

for i in range(len(scores)) :
    for j in range(len(scores[i])) :
        scores[i][j] = scores[i][j]**(1/2)

scoreTotal49 = [scores[0][i]/3 + scores[1][i]/3 +
                scores[2][i]/3 for i in range(20)]
scoreTotal50 = [scores[3][i] for i in range(20)]
scoreTotal51 = [scores[4][i]/3 + scores[5][i]/3 +
                scores[6][i]/3 for i in range(20)]
scoreTotal53s1 = [scores[7][i]/3 + scores[8][i]/3 +
                  scores[9][i]/3 for i in range(20)]
scoreTotal53s2 = [scores[10][i]/3 + scores[11][i]/3 +
                  scores[12][i]/3 for i in range(20)]
scoreTotals = (scoreTotal49,scoreTotal50,scoreTotal51,
               scoreTotal53s1,scoreTotal53s2)

print('49',*scoreTotal49,'--', sep='\n')
print('50',*scoreTotal50,'--', sep='\n')
print('51',*scoreTotal51,'--', sep='\n')
print('53s1',*scoreTotal53s1,'--', sep='\n')
print('53s2',*scoreTotal53s2,'--', sep='\n')

best = [scores.index(min(scores)) for scores in scoreTotals]
print(best)

for file in files :
    file.close()

output = open('results.dat','w')
head = '\t'.join([str(i+1) for i in range(20)])
output.write(head+'\n')
for score in scores :
    output.write('\t'.join([str(num) for num in score])+'\n')
output.close()
