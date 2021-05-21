setwd('D:/Bork/Desktop')
data = read.table('results.dat',header=T)
mat = sqrt(as.matrix(data))
colnames(mat) = 1:20


T0949 = mat[1:3,]
T0950 = mat[4,]
T0951 = mat[c(6,5,7),]
T0953s1 = mat[c(9,8,10),]
T0953s2 = mat[c(11,13,12),]

pdf('barplots.pdf')
barplot(T0949, xlab = 'Structure', ylab = 'MSD', main = 'T0949',border = NA,
        col = c('seagreen2', 'royalblue', 'sandybrown'),
        legend = c('3X1E','4HPO','1SQB'), args.legend = c(bg = NA,bty = 'n'))
abline(min(colSums(T0949)),0,lty = "dashed")
barplot(T0950, xlab = 'Structure', ylab = 'MSD', main = 'T0950',border = NA,
        col = c('sandybrown'),
        legend = c('6EK4'), args.legend = c(bg = NA,bty = 'n'))
abline(min(T0950),0,lty = "dashed")
barplot(T0951, xlab = 'Structure', ylab = 'MSD', main = 'T0951',border = NA,
        col = c('seagreen2', 'royalblue', 'sandybrown'),
        legend = c('5CBK','3W06','5DNU'), args.legend = c(bg = NA,bty = 'n'))
abline(min(colSums(T0951)),0,lty = "dashed")
barplot(T0953s1, xlab = 'Structure', ylab = 'MSD', main = 'T0953s1',border = NA,
        col = c('seagreen2', 'royalblue', 'sandybrown'),
        legend = c('2VCY','2GMQ','4EBB'), args.legend = c(bg = NA,bty = 'n'))
abline(min(colSums(T0953s1)),0,lty = "dashed")
barplot(T0953s2, xlab = 'Structure', ylab = 'MSD', main = 'T0953s2',border = NA,
        col = c('seagreen2', 'royalblue', 'sandybrown'),
        legend = c('3EEH','6CN1','3JSA'), args.legend = c(bg = NA,bty = 'n'))
abline(min(colSums(T0953s2)),0,lty = "dashed")
dev.off()

