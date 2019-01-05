set.seed(111)
setwd("E:/proj_data/task1")
library(ROCR)
library(randomForest)

# data
X = as.matrix(read.table("train.X"))
y = as.factor(as.matrix(read.table("train.CT")))
X.test = as.matrix(read.table("dev.X"))
y.test.num = as.matrix(read.table("dev.CT"))
y.test = as.factor(y.test.num)


N = dim(X)[1] # num observations
N.test = length(y.test)

# ntree = 250; mtry = 4
rf = randomForest(x = X, y = y, ytest = y.test, xtest = X.test, importance=T, ntree=100, mtry=4,keep.forest = T)

logitr = glm(y~X, family=binomial)
y.test.fit = cbind(rep(1,N.test),X.test)%*%logitr$coefficients
y.test.pred = 1/(1+exp(-y.test.fit))
cutoff=.5
logitr.confusion = as.matrix(t(cbind(1-y.test.num,y.test.num))%*%cbind(1-(y.test.pred>=cutoff),(y.test.pred>=cutoff)))
logitr.confusion = cbind(logitr.confusion,
                         as.matrix(logitr.confusion*matrix(c(0,1,1,0),ncol=2))%*%c(1,1)/logitr.confusion%*%c(1,1))

#### ROC curves ####
# Random Forest
plot(performance(prediction(predict(rf,X.test,type="prob")[,2],y.test),"tpr","fpr"))
# Logistic Regression
plot(performance(prediction(y.test.pred,y.test),"tpr","fpr"),add=T,col="blue")
legend("bottomright",legend=c("Random Forest","Logistic Regression"),col=c("black","blue"),lty=c(1,1))

emp.risk.logitr = mean(-(y.test.num*log(y.test.pred) + (1-y.test.num)*log(1-y.test.pred)))

pred.rf.test = .01+.98*(predict(rf,X.test,type="prob")[,2])
emp.risk.rf = mean(-(y.test.num*log(pred.rf.test) + (1-y.test.num)*log(1-pred.rf.test)))
range(pred.rf.test)
