data = matrix(c(0.78, 0.78, 0.78,
0.23, 0.26, 0.14,
-0.02, -0.14, -0.14,
-2.08, -0.34, 0.97,
-1.50, -0.07, -0.27,
-3.79, -1.55, -0.60,
-1.51, -1.53, -1.50,
-3.80, -3.80, -3.73),nrow=3)
boxplot(data,main=expression(paste("Boxplot of ",Delta,Delta,"G")),
        ylab = expression(paste(Delta,Delta,"G")),
        xlab = "Mutation by Rank")
