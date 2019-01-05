##### M457 Exam 2 R Script
##### Miles Keppler
##### Takes ~40 minutes to run

library(coda)
setwd("U:/Winter 2018/M457/")
Y = as.numeric(unlist(read.table("Exam2data4.dat")))
set.seed(11)

# create clear plot with nice axes/headings
plot(NULL, ylim = c(0, .15), xlim = c(min(Y),max(Y)),
     main = "Density plot", ylab = "Density", xlab = "Height (inches)")

# histogram of Y denities
hist(Y, breaks = seq(from = floor(min(Y)), to = ceiling(max(Y)), by = .5),
     freq = F, border = "gray60", add = T)

findDensity = function(y, d) {
  e = d$x[2] - d$x[1]
  r = abs(d$x - y) <= d$x[2]-d$x[1]
  if(sum(r) == 0) {
    return(min(d$y))
  }
  return(mean(d$y[r]))
}

# Constants
N = length(Y)
kappa0 = 1 ; mu0 = 60 ; sigma2_0 = 10; nu0 = 1

# Starting values
pA = .5
vals = c(55, 65, 60)
# theta_AA = 65 ; theta_Aa = 60 ; theta_aa = 55
sigma2_AA = 3 ; sigma2_Aa = 3 ; sigma2_aa = 3

m = 1 # predictive sample size per iteration
M = 100000 # number of iterations
S = 50 # samples to reach stationarity

# create clear plot with nice axes/headings
plot(NULL, ylim = c(0, .15), xlim = c(min(Y),max(Y)),
     main = "Density plot", ylab = "Density", xlab = "Height (inches)")

# histogram of Y denities
hist(Y, breaks = seq(from = floor(min(Y)), to = ceiling(max(Y)), by = .5),
     freq = F, border = "gray80", add = T)

helpme = matrix(NA, nrow=3, ncol=3)
# to calculate Bayes factors
LOGLIKELIHOOD = NULL
for (perm in 1:3) {
  ##### to compare density plots #####
  theta_AA = max(vals[-perm])
  theta_Aa = vals[perm]
  theta_aa = min(vals[-perm])

  #### run S times, store no values ####
  for (i in 1:S) {
    X = matrix(NA, nrow = N, ncol = 3)
    for (j in 1:N) {
      pAA = pA^2 * dnorm(Y[j], mean = theta_AA, sd = sqrt(sigma2_AA))
      pAa = 2*pA*(1-pA) * dnorm(Y[j], mean = theta_Aa, sd = sqrt(sigma2_Aa))
      paa = (1-pA)^2 * dnorm(Y[j], mean = theta_aa, sd = sqrt(sigma2_aa))
      X[j,] = rmultinom(1, 1, c(pAA, pAa, paa))
    }
    n_AA = sum(X[,1]) ; ybar_AA = mean(Y[X[,1]==1]) ; s2_AA = var(Y[X[,1]==1])
    n_Aa = sum(X[,2]) ; ybar_Aa = mean(Y[X[,2]==1]) ; s2_Aa = var(Y[X[,2]==1])
    n_aa = sum(X[,3]) ; ybar_aa = mean(Y[X[,3]==1]) ; s2_aa = var(Y[X[,3]==1])
    pA = rbeta(1, 2*n_AA+n_Aa+1, n_Aa+2*n_aa+1)
    theta_AA = rnorm(1, mean = (kappa0*mu0 + n_AA*ybar_AA)/(kappa0+n_AA),
                     sd = sigma2_AA/(kappa0+n_AA))
    theta_Aa = rnorm(1, mean = (kappa0*mu0 + n_Aa*ybar_Aa)/(kappa0+n_Aa),
                     sd = sigma2_Aa/(kappa0+n_Aa))
    theta_aa = rnorm(1, mean = (kappa0*mu0 + n_aa*ybar_aa)/(kappa0+n_aa),
                     sd = sigma2_aa/(kappa0+n_aa))
    sigma2_AA = 1/rgamma(1, shape = (nu0+n_AA+1)/2,
                         rate = 1/2 * (nu0*sigma2_0 + 
                                         (n_AA - 1)*s2_AA + 
                                         (ybar_AA-mu0)^2 + 
                                         kappa0*(theta_AA - mu0)^2))
    sigma2_Aa = 1/rgamma(1, shape = (nu0+n_Aa+1)/2,
                         rate = 1/2 * (nu0*sigma2_0 + 
                                         (n_Aa - 1)*s2_Aa + 
                                         (ybar_Aa-mu0)^2 +
                                         kappa0*(theta_Aa - mu0)^2))
    sigma2_aa = 1/rgamma(1, shape = (nu0+n_aa+1)/2,
                         rate = 1/2 * (nu0*sigma2_0 + 
                                         (n_aa - 1)*s2_aa + 
                                         (ybar_aa-mu0)^2 + 
                                         kappa0*(theta_aa - mu0)^2))
  }
  
  ##### Gibbs sampler #####
  THETAS = matrix(NA, nrow = M, ncol = 3)
  SIGMAS = matrix(NA, nrow = M, ncol = 3)
  PAS = matrix(NA, nrow = M, ncol = 1)
  NEWYS = matrix(NA, nrow = M, ncol = m)
  
  for (i in 1:M) {
    # Generate new X
    # X[1,i] = 1 if Y[i] has genotype AA
    # X[2,i] = 1 if Y[i] has genotype Aa
    # X[3,i] = 1 if Y[i] has genotype aa
    X = matrix(NA, nrow = N, ncol = 3)
    for (j in 1:N) {
      pAA = pA^2 * dnorm(Y[j], mean = theta_AA, sd = sqrt(sigma2_AA))
      pAa = 2*pA*(1-pA) * dnorm(Y[j], mean = theta_Aa, sd = sqrt(sigma2_Aa))
      paa = (1-pA)^2 * dnorm(Y[j], mean = theta_aa, sd = sqrt(sigma2_aa))
      X[j,] = rmultinom(1, 1, c(pAA, pAa, paa))
    }
    # constants given X, Y
    n_AA = sum(X[,1]) ; ybar_AA = mean(Y[X[,1]==1]) ; s2_AA = var(Y[X[,1]==1])
    n_Aa = sum(X[,2]) ; ybar_Aa = mean(Y[X[,2]==1]) ; s2_Aa = var(Y[X[,2]==1])
    n_aa = sum(X[,3]) ; ybar_aa = mean(Y[X[,3]==1]) ; s2_aa = var(Y[X[,3]==1])
    
    # Generate new pA
    pA = rbeta(1, 2*n_AA+n_Aa+1, n_Aa+2*n_aa+1)
    
    # Generate new theta_AA, theta_Aa, theta_aa
    theta_AA = rnorm(1, mean = (kappa0*mu0 + n_AA*ybar_AA)/(kappa0+n_AA),
                     sd = sigma2_AA/(kappa0+n_AA))
    theta_Aa = rnorm(1, mean = (kappa0*mu0 + n_Aa*ybar_Aa)/(kappa0+n_Aa),
                     sd = sigma2_Aa/(kappa0+n_Aa))
    theta_aa = rnorm(1, mean = (kappa0*mu0 + n_aa*ybar_aa)/(kappa0+n_aa),
                     sd = sigma2_aa/(kappa0+n_aa))
    
    # Genereate new sigma2_AA, sigma2_Aa, sigma2_aa
    sigma2_AA = 1/rgamma(1, shape = (nu0+n_AA+1)/2,
                         rate = 1/2 * (nu0*sigma2_0 +
                                         (n_AA - 1)*s2_AA +
                                         (ybar_AA-mu0)^2 +
                                         kappa0*(theta_AA - mu0)^2))
    sigma2_Aa = 1/rgamma(1, shape = (nu0+n_Aa+1)/2,
                         rate = 1/2 * (nu0*sigma2_0 +
                                         (n_Aa - 1)*s2_Aa +
                                         (ybar_Aa-mu0)^2 +
                                         kappa0*(theta_Aa - mu0)^2))
    sigma2_aa = 1/rgamma(1, shape = (nu0+n_aa+1)/2,
                         rate = 1/2 * (nu0*sigma2_0 +
                                         (n_aa - 1)*s2_aa +
                                         (ybar_aa-mu0)^2 +
                                         kappa0*(theta_aa - mu0)^2))
    
    # Generate predictive sample size m
    newYs = rep(NA, m)
    for (j in 1:m) {
      y = NA
      x = rmultinom(1, 1, c(pA^2, 2*pA*(1-pA), (1-pA)^2))
      if (x[1]==1) {
        y = rnorm(1, theta_AA, sqrt(sigma2_AA))
      } else if (x[2]==1) {
        y = rnorm(1, theta_Aa, sqrt(sigma2_Aa))
      } else {
        y = rnorm(1, theta_aa, sqrt(sigma2_aa))
      }
      newYs[j] = y
    }
    
    # Store generated values
    THETAS[i,] = c(theta_AA, theta_Aa, theta_aa)
    SIGMAS[i,] = c(sigma2_AA, sigma2_Aa, sigma2_aa)
    PAS[i,] = pA
    NEWYS[i,] = newYs
  }
  
  # calculate p(Y| ...)
  d = density(NEWYS)
  loglikelihood = 0
  for (y in Y) {
    loglikelihood = loglikelihood + log(findDensity(y, d))
  }
  LOGLIKELIHOOD = rbind(LOGLIKELIHOOD, loglikelihood)
  
  ##### plot density curve #####
  lines(d, lty = perm, xlab = "Height (inches)", main = "Density plot",
        col = paste("gray", 75-perm*25, sep = ""))
}
legend("topright", 
       legend = as.expression(c(bquote(paste("predictive ",
                                             (theta[Aa]^(0) == .(vals[1])))),
                                bquote(paste("predictive ",
                                             (theta[Aa]^(0) == .(vals[2])))),
                                bquote(paste("predictive ",
                                             (theta[Aa]^(0) == .(vals[3])))))),
       lty = 1:3, col = c("gray50", "gray25", "gray0"))

# final THETAS, SIGMAS, PAS, NEWYS should be for best model (theta_Aa^(0) = 60)

PHI = cbind(THETAS, SIGMAS, PAS)
colnames(PHI) = c("theta_AA", "theta_Aa", "theta_aa", 
                  "sigma2_AA", "sigma2_Aa", "sigma2_aa", "pA")

##### find (log) Bayes factor #####
LBF = matrix(NA, nrow = 3, ncol = 3)
for (i in 1:3) {
  for (j in (1:3)) {
    LBF[i,j] = LOGLIKELIHOOD[i]-LOGLIKELIHOOD[j]
  }
}
BF = exp(LBF)
PBF = 1/(1+BF^(-1))
# BF[i,j] Bayes factor to prefer model i over model j

ES = effectiveSize(as.mcmc(PHI))

bigsigma = matrix(NA, nrow = M, ncol = 1)
for (i in 1:M) {
  bigsigma[i] = which(SIGMAS[i,]==max(SIGMAS[i,]))
}
biggestsigma = c(sum(bigsigma==1), sum(bigsigma==2), sum(bigsigma==3))/M

#### predict X for given Y ####
I100 = 51.83806
XI100 = matrix(NA, nrow = M, ncol = 3)
for (i in 1:M) {
  theta_AA = THETAS[i,1] ; theta_Aa = THETAS[i,2] ; theta_aa = THETAS[i,3]
  sigma2_AA = SIGMAS[i,1] ; sigma2_Aa = SIGMAS[i,2] ; sigma2_aa = SIGMAS[i,3]
  pA = PAS[i,1]
  pAA = pA^2 * dnorm(I100, mean = theta_AA, sd = sqrt(sigma2_AA))
  pAa = 2*pA*(1-pA) * dnorm(I100, mean = theta_Aa, sd = sqrt(sigma2_Aa))
  paa = (1-pA)^2 * dnorm(I100, mean = theta_aa, sd = sqrt(sigma2_aa))
  XI100[i,] = rmultinom(1, 1, c(pAA, pAa, paa))
}

pXI100 = colSums(XI100)/M

HPDinterval(as.mcmc(PHI))
HPDinterval(as.mcmc(cbind(PAS,PAS^2,2*PAS*(1-PAS),(1-PAS)^2)))

boxplot(SIGMAS, main = "Boxplot of Variances",
        names = c(expression(sigma[AA]^2),expression(sigma[Aa]^2),
                  expression(sigma[aa]^2)))

# create clear plot with nice axes/headings
plot(NULL, ylim = c(0, .15), xlim = c(min(Y),max(Y)),
     main = expression(paste("Density plot for E[",phi,"]")),
     ylab = "Density", xlab = "Height (inches)")

# histogram of Y denities
hist(Y, breaks = seq(from = floor(min(Y)), to = ceiling(max(Y)), by = .5),
     freq = F, border = "gray80", add = T)
# plots of means of parameters
pA = mean(PAS)
sigmas = colMeans(SIGMAS)
thetas = colMeans(THETAS)
curve(pA^2*dnorm(x,thetas[1],sqrt(sigmas[1])),lty=2,add=T)
curve(2*pA*(1-pA)*dnorm(x,thetas[2],sqrt(sigmas[2])),lty=1,add=T)
curve((1-pA)^2*dnorm(x,thetas[3],sqrt(sigmas[3])),lty=4,add = T)
# posterior density plot
lines(d, lty = 3, col = "gray0")
legend("topright", legend = c(expression(p[A]^2*f[AA](y)),
                              expression(2*p[A](1-p[A])*f[Aa](y)),
                              expression((1-p[A])^2*f[aa](y)),
                              "Posterior approximation"),
       lty = c(2,1,4,3))
