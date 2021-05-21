# setup
library(igraph)

setwd("~");
BigG = read_graph("./EATnew.net", format="pajek");


# measures
WordLen = nchar(vertex_attr(BigG)$id);
EigenCentr = centr_eigen(BigG)$vector;
BetwCentr = centr_betw(BigG)$res;
CloseCentr = centr_clo(BigG)$res;
DegCentr = centr_degree(BigG)$res;
Phrase = (unlist(lapply(strsplit(vertex_attr(BigG)$id, " "), length)) - 1);

# main data frame
prop = 0;
pairing = data.frame(
	vertex_attr(BigG)$id[EigenCentr>quantile(EigenCentr, prop)],
	EigenCentr[EigenCentr>quantile(EigenCentr, prop)],
	WordLen[EigenCentr>quantile(EigenCentr, prop)]);
colnames(pairing) = c("Word", "Eigenvector Centrality", "Word Length");
#write.csv(pairing, file="./pajek/top2tenthpercentile.csv");

hist(pairing[,2], xlab="Eigenvector Centrality", main="Histogram of Eigenvector Centrality", freq=F);
hist(pairing[,3], xlab="Word Length", main="Histogram of Word Length", freq=F);
plot(pairing[,3], pairing[,2], xlab="Word Length", ylab="Centrality", main="Eigenvector Centrality and Word Length");

# main lin reg model

meanagg = aggregate(pairing[,2], list(pairing[,3]), mean);
colnames(meanagg) = c("Word Length", "Mean Eigenvector Centrality");

fred = lm(1/meanagg[6:15,2]~meanagg[6:15,1])

# main lin reg plotting
plot(pairing[,3], pairing[,2], pch=24, col="dark grey",
     xlab="Word Length", ylab="Eigenvector Centrality", main="Fitting y = 1/(a+bx)");
points(meanagg, pch=22, bg="blue");
curve(1/(fred$coef[1]+fred$coef[2]*x),from=0, add=T,col="red",lwd=2);
legend(x=20, y=.9, legend=c("Data Point", "Mean", "Best Fit 'Line'"),
       lwd=c(NA,NA,2), col=c("dark grey", "black", "red"), pch=c(24,22,NA), pt.bg=c(NA,"blue",NA));

plot(meanagg, pch=22, bg="blue", xlab="Word Length", ylab="Eigenvector Centrality", main="Fitting y = 1/(a+bx)");
curve(1/(fred$coef[1]+fred$coef[2]*x),from=0, add=T,col="red",lwd=2);
legend(x=20, y=.05, legend=c("Mean", "Best Fit 'Line'"),
       lwd=c(NA,2), col=c("black", "red"), pch=c(22,NA), pt.bg=c("blue",NA));

plot(meanagg, pch=22, bg="blue", xlab="Word Length", ylab="Eigenvector Centrality", main="Fitting y = 1/(a+bx)",
     xlim=c(4,16));
curve(1/(fred$coef[1]+fred$coef[2]*x),from=0, add=T,col="red",lwd=2);
legend(x=13, y=.05, legend=c("Mean", "Best Fit 'Line'"),
       lwd=c(NA,2), col=c("black", "red"), pch=c(22,NA), pt.bg=c("blue",NA));

# aggregates for plotting
medagg = aggregate(pairing[,2], list(pairing[,3]), median);
colnames(medagg) = c("Word Length", "Median Eigenvector Centrality");
plot(medagg);

lagg = aggregate(pairing[,3], list(pairing[,3]), length);
colnames(lagg) = c("Word Length", "Number of Words");
plot(lagg);

varagg = aggregate(pairing[,2], list(pairing[,3]), var);
colnames(varagg) = c("Word Length", "Eigenvector Centrality Variance");
plot(varagg);

recvaragg = aggregate(1/pairing[,2], list(pairing[,3]), var);
colnames(recvaragg) = c("Word Length", "Reciprocal Eigenvector Centrality Variance");
plot(recvaragg);

plot(varagg[,2]/lagg[,2], xlab="Word Length", ylab="Variance",
     main="Variance of Mean Eigenvector Centrality");

plot(recvaragg[,2]/lagg[,2], xlab="Word Length", ylab="Variance",
     main="Variance of Mean Reciprocal Eigenvector Centrality");

# clustering/communities
clust = cluster_louvain(as.undirected(BigG));
clust.graph = contract.vertices(as.undirected(BigG), clust$membership, vertex.attr.comb=list(size="sum", "ignore"));
clust.graph = simplify(clust.graph, remove.multiple=T, remove.loops=T, edge.attr.comb=list(count="sum", "ignore"));
plot(clust.graph, vertex.size=sqrt(sizes(clust)), vertex.label=sizes(clust), edge.arrow.mode="-", vertex.color="light green")

diameter(clust.graph);

sum(crossing(clust,as.undirected(BigG)));
length(E(as.undirected(BigG)))

# aggregates by community
vertclusts = data.frame(vertex_attr(BigG)$id, EigenCentr, WordLen, clust$membership)
clustaggec = aggregate(vertclusts[,2], list(vertclusts[,4]), mean);
colnames(clustaggec) = c("Community", "Mean Eigenvector Centrality")
clustaggwl = aggregate(vertclusts[,3], list(vertclusts[,4]), mean)
colnames(clustaggwl) = c("Community", "Mean Word Length")

plot(clustaggwl[,2], clustaggec[,2], pch=NA, xlab="Mean Word Length", ylab="Mean Eigenvector Centrality",
     main="Clusters Compared")
text(clustaggwl[,2], clustaggec[,2], sizes(clust))

prop = .999;
isbigg = simplify(induced_subgraph(BigG, EigenCentr>quantile(EigenCentr, prop)))
plot(isbigg, vertex.size=5, edge.arrow.mode="-", vertex.label=NA)
isbigg.clust = cluster_louvain(as.undirected(isbigg))
plot(isbigg.clust, as.undirected(isbigg), vertex.size=5)
isbigg.clust
