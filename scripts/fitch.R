#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)


suppressMessages(require(phytools))
suppressMessages(library(phangorn))


Fitch<-function(x,pw,nn,nm,return="score"){
  xx<-vector("list",Ntip(pw)+Nnode(pw))
  xx[1:Ntip(pw)]<-setNames(x,nm)[pw$tip.label]
  pp<-0
  for(i in 1:length(nn)){
    ee<-which(pw$edge[,1]==nn[i])
    Intersection<-Reduce(intersect,xx[pw$edge[ee,2]])
    if(length(Intersection)>0){ 
      xx[[nn[i]]]<-Intersection
    } else {
      xx[[nn[i]]]<-Reduce(union,xx[pw$edge[ee,2]])
      pp<-pp+1
    }
  }
  if(return=="score") pp else if(return=="nodes") xx
}
pscore<-function(tree,x,...){
  pw<-if(!is.null(attr(tree,"order"))&&
      attr(tree,"order")=="postorder") tree else 
    reorder(tree,"postorder")
  nn<-unique(pw$edge[,1])
  if(is.matrix(x)||is.data.frame(x)){
    nm<-rownames(x)
    apply(x,2,Fitch,pw=pw,nn=nn,nm=nm,...)
  } else {
    nm<-names(x)
    Fitch(x,pw,nn,nm,...)
  }
}


table_genetrees <- read.table(file = args[1], sep = "\t") 

for (i in 1:dim(table_genetrees)[1]) {

  tree <-  table_genetrees$V2[i]
	tree <- read.newick(text=tree)

	parthenogens=c("TDI","TSI","TMS","TGE","TTE")
  bisexualsspp=c("TPA","TCE","TCM","TPS","TBI")
	
	prt<-length(intersect(parthenogens, tree$tip.label))
	bsx<-length(intersect(bisexualsspp, tree$tip.label))

	trait = read.table(file = args[2], sep = "\t", header = T)

	row.names(trait) = trait$sp
	trait$sp = NULL
	gene <- table_genetrees$V1[i]

	if ((prt - pscore(tree,trait)) == 0) {
                cat(gene, "full homoplasy", "\t", pscore(tree,trait), "\t", prt, "\t", bsx, "\t", length( tree$tip.label))
                cat("", sep="\n")

        } else if ((pscore(tree,trait)) == 1) {
                cat(gene, "full hemiplasy", "\t", pscore(tree,trait), "\t", prt, "\t", bsx, "\t", length( tree$tip.label))
                cat("", sep="\n")

	} else {
		cat(gene, "some hemiplasy", "\t", pscore(tree,trait), "\t", prt, "\t", bsx, "\t", length( tree$tip.label))
		cat("", sep="\n")
	}

}
