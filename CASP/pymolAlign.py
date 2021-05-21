#!/usr/bin/env python
print("Enter protein: ")
import __main__
__main__.pymol_argv = ['pymol','-qc'] # Pymol: quiet and no GUI
from time import sleep
import sys
import pymol
pymol.finish_launching()

protein = raw_input()

file1 = open('objects.txt', 'r')

objects = []
for line in file1:
        objects.append(line.rstrip())
file1.close()

file2 = open('sequence2.txt', 'r')

query = file2.readline()
subject = file2.readline()
x = int(query[:5])
y = int(subject[:5])

queryList = []
subjectList = []

j = 5
Qkey = 0
Skey = 0
k = 0
while(query[j] != ' '):
    if(query[j] == 'P' and subject[j] == 'P'):
        queryList.append(int(x) + int(Qkey))
        subjectList.append(int(y) + int(Skey))
        k = k + 1
        Qkey = Qkey + 1
        Skey = Skey + 1
    elif(query[j] == '-'):
        Skey = Skey + 1
    elif(subject[j] == '-'):
        Qkey = Qkey + 1
    else:
        Qkey = Qkey + 1
        Skey = Skey + 1
    j = j + 1

file2.close()

file3 = open('newfile','w')

for index in range(0,20):
    pymol.cmd.reinitialize()

    pymol.cmd.load('%s.pdb' %(objects[index]))

    file3.write('\n')
    file3.write(objects[index] + ":\n")
    file3.write('\n')

    for key in range(0,(k-1)):
        distance = pymol.cmd.distance("(/" + objects[index] + "///%d/CA)"%(queryList[key]),"(/" + objects[index] + "///%d/CA)"%(queryList[key+1]))
        file3.write("Distance between %d-%d: %s\n"%(queryList[key], queryList[key+1], distance))

    sleep(0.5) # (in seconds)

pymol.cmd.reinitialize()
pymol.cmd.fetch('%s' %(protein))

file3.write('\n')
file3.write(protein + ":\n")
file3.write('\n')

for key in range(0,(k-1)):
    distance = pymol.cmd.distance("(/" + protein + "///%d/CA)"%(subjectList[key]) ,"(/" + protein + "///%d/CA)"%(subjectList[key+1]))
    file3.write("Distance between %d-%d: %s\n"%(subjectList[key], subjectList[key+1], distance))


    sleep(0.5) # (in seconds)

file3.close()

pymol.cmd.quit()

