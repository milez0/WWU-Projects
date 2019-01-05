#### Math 457 ####
#### Final Exam ####
#### Miles Keppler ####

setwd("U:/Winter 2018/M457/")
library(coda)

#### 1 ####

mean.theta = .03
sd.theta = .07/2
beta = mean.theta / sd.theta^2
alpha = beta * mean.theta

alpha/(25+beta)

qbeta(.95, alpha, beta+25)

curve(dbeta(x,alpha,beta),lty=2,col="gray60")
curve(dbeta(x,alpha,beta+25),add=T)
legend("topright",legend=c("Prior","Posterior"),lty=c(2,1),col=c("gray60","black"))

#### 2 ####

# gprior function from
# http://wwwlegacy.stat.washington.edu/people/pdhoff/Book/ComputerCode/regression_gprior.r
lm.gprior<-function(y,X,g=dim(X)[1],nu0=1,
                    s20=try(summary(lm(y~-1+X))$sigma^2,silent=TRUE),S=1000) {
  n<-dim(X)[1] ; p<-dim(X)[2]
  Hg<- (g/(g+1))*X%*%solve(t(X)%*%X)%*%t(X)
  SSRg<- t(y)%*%(diag(1,nrow=n)-Hg)%*%y
  
  s2<-1/rgamma(S,(nu0+n)/2,(nu0*s20+SSRg)/2)
  
  Vb<- g*solve(t(X)%*%X)/(g+1)
  Eb<- Vb%*%t(X)%*%y
  
  E<-matrix(rnorm(S*p,0,sqrt(s2)),S,p)
  beta<-t(t(E%*%chol(Vb))+c(Eb))
  
  list(beta=beta,s2=s2)
}

data = read.table("GPAdata.dat",header = T)
Y = data$y
X = cbind(data$x1,data$x2)
n = length(Y)
S = 1000000
myglm = lm.gprior(y = Y, X = X, g = n, nu0 = 2, s20 = .4^2, S = S)

colMeans(myglm$beta)
HPDinterval(as.mcmc(myglm$beta))

fredmean = 70*myglm$beta[,1]+80*myglm$beta[,2]
HPDinterval(as.mcmc(fredmean))

fredsample = fredmean+rnorm(S,0,sqrt(myglm$s2))
HPDinterval(as.mcmc(fredsample))
hist(fredsample,probability=T,main="Histogram of Fred's predicted GPA",xlab="GPA")

marysample = 65*myglm$beta[,1]+90*myglm$beta[,2]+rnorm(S,0,sqrt(myglm$s2))
sum(marysample>fredsample)/S

#### 3 ####

set.seed(111)
Y = scan("menchild30nobach.dat")

findMass = function(x, t) {
  n = as.numeric(names(t))
  for (i in 1:length(n)) {
    if (n[i] == x) {
      return(as.numeric(t)[i])
    }
  }
  return(0)
}

# Gibbs sampler (mixture model)
# should look like scaled poisson plus mass at 0

n = length(Y)
p = .5
theta = 2

M = 100000

PHI = matrix(NA, ncol = 2, nrow = M)
for (i in 1:M) {
  X = NULL
  for (j in 1:n) {
    if (Y[j]==0) {
      X[j] = rbinom(1,1,(1-p)*exp(-theta)/(p+(1-p)*exp(-theta)))
    } else {
      X[j] = 1
    }
  }
  sx = sum(X)
  p = rbeta(1,sx+1,n-sx+1)
  theta = rgamma(1,sum(Y[X==1])+1,sx + 1/3)
  PHI[i,] = c(theta, p)
}

NY = rep(NA, M)
for (i in 1:M) {
  theta = PHI[i,1]
  p = PHI[i,2]
  x = rbinom(1,1,p)
  ny = 0
  if (x==1) {
    ny = rpois(1, theta)
  }
  NY[i] = ny
}

# Plotting

# Empirical
taby = table(Y)/n
tabny = table(NY)/M
yind = as.numeric(names(taby))
plot(as.numeric(yind),c(taby),type="h",ylim = c(0,max(c(taby,tabny))),lwd=10,
     main = "Probability Mass", xlab = "Children", ylab = "Density", xlim = c(0-.1, max(yind))+.1)
# Mixture Poisson
nyind = as.numeric(names(tabny))
points(as.numeric(nyind)+.1,c(tabny),type="h",lwd=10,col="gray75")
# Poisson model
points(0:max(yind)-.1,dpois(min(yind):max(yind),mean(Y)),type="h",lwd=10,col="gray50")

p = sum(Y==0)/n
mytab = as.table(c(p,(1-p)*dpois(as.numeric(names(taby))[-1]-1,mean(Y[Y!=0]-1))))
names(mytab) = mytab.names = 0:(length(mytab)-1)
points(mytab.names+.2,mytab,type="h",lwd=10,col="gray90")

legend("topright", legend = c("Empirical","Simple Poisson","Mixture Poisson","Shifted Poisson"),
       lwd = c(5,5,5,5), col = c("black","gray50","gray75","gray90"))

LL = c(0,0,0)
for (i in 1:n) {
  LL[1] = LL[1] + log(findMass(Y[i], tabny))
  LL[2] = LL[2] + log(dpois(Y[i],mean(Y)))
  LL[3] = LL[3] + log(findMass(Y[i], mytab))
}
bf = c(exp(LL[1]-LL[2]), exp(LL[3]-LL[1]))
bf ; bf/(1+bf)

nLL = 0
for (i in 1:n) {
  nLL = nLL + log(findMass(Y[i],taby))
}
