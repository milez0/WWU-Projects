library(igraph)

setwd("~");
G = read_graph("./pajek/reducedEATnew.net", format="pajek");

Gu = as.undirected(G);

comm = cluster_louvain(Gu);

plot(comm, Gu, vertex.size = 2, vertex.label = NA);

png("./pajek/communityvisualization.png");
dev.off();

# other stuff

Gclq = largest_cliques(G);
Gcomp = components(G);

# largest connected subgraph
lcsG = delete_vertices(G, V(G)[Gcomp$csize[Gcomp$membership]!=max(Gcomp$csize)]);

# disconnected subgraphs
dcG = delete_vertices(G, V(G)[Gcomp$csize[Gcomp$membership]==max(Gcomp$csize)]);

vertex_attr(lcsG)

plot(lcsG, vertex.size = 2, vertex.label = NA, edge.arrow.mode="-");
plot(dcG, vertex.size = 2, vertex.label = NA, edge.arrow.mode="-");

X = nchar(vertex_attr(G)$id);
Y1 = centr_eigen(G)$vector;
Y2 = centr_betw(G)$res;
Y3 = centr_clo(G)$res;
Y4 = centr_degree(G)$res;

pairs(X~Y1 + Y2 + Y3 + Y4)

x = seq(1,max(X));
y1 = c();
y2 = c();
y3 = c();
y4 = c();
for (i in x) {
	y1 = c(y1,mean(Y1[X==i]))
	y2 = c(y2,mean(Y2[X==i]))
	y3 = c(y3,mean(Y3[X==i]))
	y4 = c(y4,mean(Y4[X==i]))
}

par(mfrow=c(2,2));
plot(y1, main="Eigen", ylab="Mean Centrality", xlab="Word Length");
plot(y2, main="Between", ylab="Mean Centrality", xlab="Word Length");
plot(y3, main="Close", ylab="Mean Centrality", xlab="Word Length");
plot(y4, main="Degree", ylab="Mean Centrality", xlab="Word Length");


# BIG GRAPH

BigG = read_graph("./pajek/EATnew.net", format="pajek");

WordLen = nchar(vertex_attr(BigG)$id);
EigenCentr = centr_eigen(BigG)$vector;
BetwCentr = centr_betw(BigG)$res;
CloseCentr = centr_clo(BigG)$res;
DegCentr = centr_degree(BigG)$res;

# PAIRS
#
# par(mfrow=c(1,1));
# png("./pajek/pairs.png");
# dev.off();
#

pairs(WordLen~EigenCentr+BetwCentr+CloseCentr+DegCentr);

x = seq(1,max(WordLen));
y1 = c();
y2 = c();
y3 = c();
y4 = c();
for (i in x) {
	y1 = c(y1,mean(EigenCentr[WordLen==i]))
	y2 = c(y2,mean(BetwCentr[WordLen==i]))
	y3 = c(y3,mean(CloseCentr[WordLen==i]))
	y4 = c(y4,mean(DegCentr[WordLen==i]))
}

par(mfrow=c(2,2));

# MEAN PLOTS
#
# png("./pajek/meanplots.png");
# dev.off();
#

plot(y1, main="Eigenvector Centrality", ylab="Mean", xlab="Word Length");
plot(y2, main="Betweenness Centrality", ylab="Mean", xlab="Word Length");
plot(y3, main="Closeness Centrality", ylab="Mean", xlab="Word Length");
plot(y4, main="Degree Centrality", ylab="Mean", xlab="Word Length");

# Linearization

x = seq(1,max(WordLen));
y1 = c();
y2 = c();
y3 = c();
y4 = c();
for (i in x) {
	y1 = c(y1,mean(1/EigenCentr[WordLen==i]))
	y2 = c(y2,mean(1/(BetwCentr[WordLen==i]+1)))
	y3 = c(y3,mean(1/CloseCentr[WordLen==i]))
	y4 = c(y4,mean(1/DegCentr[WordLen==i]))
}

par(mfrow=c(2,2));

# LIN MEAN PLOTS
#
# png("./pajek/linmeanplots.png");
# dev.off();
#

plot(y1, main="Eigenvector Centrality", ylab="Mean", xlab="Word Length");
plot(y2, main="Betweenness Centrality", ylab="Mean", xlab="Word Length");
plot(y3, main="Closeness Centrality", ylab="Mean", xlab="Word Length");
plot(y4, main="Degree Centrality", ylab="Mean", xlab="Word Length");

m1 = lm(y1~x);
m2 = lm(y2~x);
m3 = lm(y3~x);
m4 = lm(y4~x);

summary(m1)
summary(m2)
summary(m3)
summary(m4)

# png("./pajek/qqplots.png");
# dev.off();

qqnorm(m1$res);
qqline(m1$res);
qqnorm(m2$res);
qqline(m2$res);
qqnorm(m3$res);
qqline(m3$res);
qqnorm(m4$res);
qqline(m4$res);

qqplot(x,m1$res);
qqplot(x,m2$res);
qqplot(x,m3$res);
qqplot(x,m4$res);


pairs(WordLen~log(EigenCentr)+log(BetwCentr)+log(DegCentr));

png("./pajek/invvar.png");

x = seq(1,max(WordLen));
y1 = c();
y2 = c();
y3 = c();
y4 = c();
for (i in x) {
	y1 = c(y1,var(1/(EigenCentr[WordLen==i])^2))
	y2 = c(y2,var(1/(BetwCentr[WordLen==i]+1)^2))
	y3 = c(y3,var(1/(CloseCentr[WordLen==i])^2))
	y4 = c(y4,var(1/(DegCentr[WordLen==i])^2))
length(WordLen[WordLen==i])
}
par(mfrow=c(2,2));
plot(y1, main="inv Eigenvector Centrality", ylab="Variance", xlab="Word Length");
plot(y2, main="inv Betweenness Centrality", ylab="Variance", xlab="Word Length");
plot(y3, main="inv Closeness Centrality", ylab="Variance", xlab="Word Length");
plot(y4, main="inv Degree Centrality", ylab="Variance", xlab="Word Length");



dev.off();

# par(mfrow=c(5,6));

x = seq(1,max(WordLen));
for (i in x) {
	#hist(log(EigenCentr[WordLen==i]));
	#hist(log(BetwCentr[WordLen==i]+1));
	#hist(log(CloseCentr[WordLen==i]));
	#hist(log(DegCentr[WordLen==i]));
	#readline();
}

x=3;
mean(log(BetwCentr[WordLen==x]));
var(log(BetwCentr[WordLen==x]));


# dev.off();


