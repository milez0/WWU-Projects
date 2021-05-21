library(igraph);

g = read_graph("EATnew.net", format="pajek");
G = g;

gs = simplify(g, remove.loops = T);

# keep only top 5% of vertices

gsv.cutoff = quantile(strength(gs, mode="in"), prob = .95);
gsv = delete_vertices(gs, which(strength(gs, mode="in")<gsv.cutoff));

# keep only top 5% of remaining edges

gsve.cutoff = quantile(E(gsv)$weight, prob = .95);
gsve = delete_edges(gsv, E(gsv)[weight<gsve.cutoff]);

# remove all vertices with no in-degree

while (min(degree(gsve, mode="in")) < 1) {
	gsve = delete_vertices(gsve, which(degree(gsve, mode="in")<1));
}

#plot.igraph(gsve, vertex.label = NA, edge.label = NA, vertex.size = 2, edge.arrow.mode = "-");

write_graph(gsve, "reducedEATnew.net", format="pajek");
