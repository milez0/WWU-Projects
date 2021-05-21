file = open('server01_TS1','r')
FASTA = ''
i = 0
for line in file:
    if line.startswith('ATOM'):
        x = int(line[23:26])
        print(x)
        if i < x:
            i = i + 1
            a = line[17:20]
            print(a)
            if a == 'ALA':
                FASTA = FASTA + 'A'
            elif a == 'ARG':
                FASTA = FASTA + 'R'
            elif a == 'ASN':
                FASTA = FASTA + 'N'
            elif a == 'ASP':
                FASTA = FASTA + 'D'
            elif a == 'ASX':
                FASTA = FASTA + 'B'
            elif a == 'CYS':
                FASTA = FASTA + 'C'
            elif a == 'GLU':
                FASTA = FASTA + 'E'
            elif a == 'GLN':
                FASTA = FASTA + 'Q'
            elif a == 'GLX':
                FASTA = FASTA + 'Z'
            elif a == 'GLY':
                FASTA = FASTA + 'G'
            elif a == 'HIS':
                FASTA = FASTA + 'H'
            elif a == 'ILE':
                FASTA = FASTA + 'I'
            elif a == 'LEU':
                FASTA = FASTA + 'L'
            elif a == 'LYS':
                FASTA = FASTA + 'K'
            elif a == 'MET':
                FASTA = FASTA + 'M'
            elif a == 'PHE':
                FASTA = FASTA + 'F'
            elif a == 'PRO':
                FASTA = FASTA + 'P'
            elif a == 'SER':
                FASTA = FASTA + 'S'
            elif a == 'THR':
                FASTA = FASTA + 'T'
            elif a == 'TRP':
                FASTA = FASTA + 'W'
            elif a == 'TYR':
                FASTA = FASTA + 'Y'
            elif a == 'VAL':
                FASTA = FASTA + 'V'
            else:
                FASTA = FASTA + 'error'

file.close()
file2 = open('test.txt','w')
file2.write(FASTA)
file2.close()

