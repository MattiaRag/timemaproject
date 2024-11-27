#!/usr/bin/env Rscript

################################################################################################### requirements ####

args = commandArgs(trailingOnly=TRUE)

suppressMessages(library(ape))
suppressMessages(library(geiger))
suppressMessages(library(phytools))
suppressMessages(library(ggplot2))

################################################################################################### reduced dataset input ####

tree <- read.nexus("MCC_sampling_reduced.tree")                                                        #import a consensus of trees

trees <- read.nexus("1k_random_sampling_reduced.trees")                                                #import a distribution of trees
class(trees)<-"multiPhylo"
data <- read.table("reproductive_strategies_reduced.tsv",header=T,row.names = 1, sep="\t")    #import binary data

chk <- name.check(tree,data)
trait <- setNames(as.factor(data[,"Value"]),rownames(data))

trees<-lapply(trees,drop.tip,tip=chk$tree_not_data)
class(trees)<-"multiPhylo"

################################################################################################### reduced dataset single tree ####

tree <- drop.tip(tree, tip=chk$tree_not_data)

levels(trait)

trait_cols <- setNames(c(
  levels(trait)[1],
  levels(trait)[2]),
  c("lightblue",
    "orange"))

ER <- fitDiscrete(tree, trait, model="ER")
SYM <- fitDiscrete(tree,trait,model="SYM")
ARD <- fitDiscrete(tree,trait,model="ARD")

aicc<-setNames(c(ER$opt$aicc,
                 SYM$opt$aicc,
                 ARD$opt$aicc),
               c("Equal Rates",
                 "Symmetrical",
                 "All Rates Different"))
aicw(aicc)

ER$opt$q12               # from bisexual to parthenogenetic rate
ER$opt$q21               # from parthenogenetic to bisexual rate

Object=make.simmap(tree=tree,x=trait, model="ER", nsim=100)
Description=describe.simmap(Object)

dMap<-densityMap(Object, res=100, fsize=.25, ftype=NULL, lwd=3, colors=trait_cols)

trait_cols<-setNames(c("lightblue","orange"),levels(trait))
dMap<-setMap(dMap,trait_cols)

plot(dMap,fsize=.25,lwd=3, legend = F)
add.color.bar(20, dMap$cols, title="PP(parthenogen)",prompt=FALSE,lwd=6, subtitle="", y=0.5)

################################################################################################### reduced dataset stochastic simulations param ####

ntre = 10

step_l <- .2           # these are the model rate numerical value, based on parameters optimization
max_l <- 4

step_j <- 10              # these are "improbabilities" to shift from parthenogenesis to bisexuality
max_j <- 100

################################################################################################### reduced dataset stochastic simulations param ####

l=seq(step_l,max_l, by=step_l)         # these are the model rate numerical value, based on parameters optimization
j=seq(step_j,max_j, by=step_j)         # these are "improbabilities" to shift from parthenogenesis to bisexuality

length(l)
length(j)

################################################################################################### reduced dataset stochastic simulations param ####

overall <- matrix(nrow=1, ncol=3) 
colnames(overall) <- c("impro","root_p","param_rate")
overall <- data.frame(overall)

################################################################################################### reduced dataset stochastic simulations first side ####

for(k in 1:length(l)) {                # these are the model rate numerical value, based on parameters optimization
  for(i in 1:length(j)) {              # these are "improbabilities" to shift from parthenogenesis to bisexuality

    tmp <- matrix(nrow=1, ncol=3) 
    colnames(tmp) <- c("impro","root_p","param_rate")
    tmp <- data.frame(tmp)
    
    Q=matrix(c(-(l[k]/j[i]),l[k],(l[k]/j[i]),-l[k]),2,2)              #recursively build the matrix
    
    rownames(Q)<-colnames(Q)<-c("B","P")
    trees_subsampled<-sample(trees,size = ntre)
    Object=make.simmap(tree=trees_subsampled,x=trait, Q=Q, nsim = ntre)
    Object=describe.simmap(Object)
    #Object
    #plot(Object,fsize=.25,cex=.5, legend = T)
    root_pt_prob <- Object$ace[1,2]
    #part_time <- mean(Object$times[,2])/mean(Object$times[,3])
    
    
    tmp[1,1] <- j[i]                   # improprobability to shift from parthenogenesis to bisexuality
    tmp[1,2] <- root_pt_prob           # probability of root beeing parthenogenetic
    tmp[1,3] <- l[k]                   # model rate numerical value
    
    overall <- rbind(tmp, overall)
  }
}

################################################################################################### reduced dataset stochastic simulations param ####

l=seq(step_l,max_l, by=step_l)         # these are the model rate numerical value, based on parameters optimization
j=seq(0.1,max_j+step_j, by=step_j)     # these are "improbabilities" to shift from parthenogenesis to bisexuality

################################################################################################### reduced dataset stochastic simulations second side ####

for(k in 1:length(l)) {                # these are the model rate numerical value, based on parameters optimization
  for(i in 1:length(j)) {              # these are "improbabilities" to shift from parthenogenesis to bisexuality
    
    tmp <- matrix(nrow=1, ncol=3) 
    colnames(tmp) <- c("impro","root_p","param_rate")
    tmp <- data.frame(tmp)
    
    Q=matrix(c(-(l[k]/j[i]),l[k],(l[k]/j[i]),-l[k]),2,2)              #recursively build the matrix
    
    rownames(Q)<-colnames(Q)<-c("B","P")
    trees_subsampled<-sample(trees,size = ntre)
    Object=make.simmap(tree=trees_subsampled,x=trait, Q=Q, nsim = ntre)
    Object=describe.simmap(Object)
    #Object
    #plot(Object,fsize=.25,cex=.5)
    root_pt_prob <- Object$ace[1,2]
    tmp[1,1] <- -j[i]               # improprobability to shift from parthenogenesis to bisexuality
    tmp[1,2] <- root_pt_prob        # probability of root beeing parthenogenetic
    tmp[1,3] <- l[k]                # model rate numerical value
    
    overall <- rbind(tmp, overall)
  }
}

################################################################################################### reduced dataset plot ####

overall <- na.omit(overall)

overall$impro <- as.character(overall$impro)
overall$param_rate <- as.character(overall$param_rate)

overall$impro <- as.numeric(overall$impro)
overall$param_rate <- as.numeric(overall$param_rate)

overall[order(overall$root_p, decreasing = TRUE), ]
overall[order(overall$root_p), ]

  
ggplot(overall, aes(x=impro, y=param_rate, fill=root_p)) +
  geom_tile(color = "white", lwd = .75) + 
  scale_fill_gradient2("p. root", low="lightblue", mid = "gray95", high="orange", midpoint = 0.5, limits = c(.0,1)) +
  labs(x = "relative probability of shifts to bisexuality", y = "rate of model") + coord_flip() +
  theme(axis.title.x=element_blank()) + 
  theme(axis.title.y=element_blank()) + 
  theme(plot.title = element_text(size=16,face="bold")) +
  theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + theme(aspect.ratio=1)

ggsave("1C.pdf",plot = last_plot(),
       width = 12, height = 12, dpi = 300)

################################################################################################### extended dataset input ####

tree <- read.nexus("MCC_sampling_extended.tree")                                                        #import a consensus of trees

trees <- read.nexus("1k_random_sampling_extended.trees")                                                #import a distribution of trees
class(trees)<-"multiPhylo"
data <- read.table("reproductive_strategies_extended.tsv",header=T,row.names = 1, sep="\t")    #import binary data

chk <- name.check(tree,data)
trait <- setNames(as.factor(data[,"Value"]),rownames(data))

trees<-lapply(trees,drop.tip,tip=chk$tree_not_data)
class(trees)<-"multiPhylo"

################################################################################################### extended dataset single tree ####

tree <- drop.tip(tree, tip=chk$tree_not_data)

levels(trait)

trait_cols <- setNames(c(
  levels(trait)[1],
  levels(trait)[2]),
  c("lightblue",
    "orange"))

ER <- fitDiscrete(tree, trait, model="ER")
SYM <- fitDiscrete(tree,trait,model="SYM")
ARD <- fitDiscrete(tree,trait,model="ARD")

aicc<-setNames(c(ER$opt$aicc,
                 SYM$opt$aicc,
                 ARD$opt$aicc),
               c("Equal Rates",
                 "Symmetrical",
                 "All Rates Different"))
aicw(aicc)

ARD$opt$q12               # from bisexual to parthenogenetic rate
ARD$opt$q21               # from parthenogenetic to bisexual rate

Object=make.simmap(tree=tree,x=trait, model="ER", nsim=100)
Description=describe.simmap(Object)

dMap<-densityMap(Object, res=100, fsize=.25, ftype=NULL, lwd=3, colors=trait_cols)

trait_cols<-setNames(c("lightblue","orange"),levels(trait))
dMap<-setMap(dMap,trait_cols)

plot(dMap,fsize=.25,lwd=3, legend = F)
add.color.bar(20, dMap$cols, title="PP(parthenogen)",prompt=FALSE,lwd=6, subtitle="", y=0.5)

################################################################################################### extended dataset stochastic simulations param ####

ntre = 10

step_l <- 0.05           # these are the model rate numerical value, based on parameters optimization
max_l <- 1

step_j <- 10              # these are "improbabilities" to shift from parthenogenesis to bisexuality
max_j <- 100

################################################################################################### extended dataset stochastic simulations param ####

l=seq(step_l,max_l, by=step_l)         # these are the model rate numerical value, based on parameters optimization
j=seq(step_j,max_j, by=step_j)         # these are "improbabilities" to shift from parthenogenesis to bisexuality

length(l)
length(j)

################################################################################################### extended dataset stochastic simulations param ####

overall <- matrix(nrow=1, ncol=3) 
colnames(overall) <- c("impro","root_p","param_rate")
overall <- data.frame(overall)

################################################################################################### extended dataset stochastic simulations first side ####

for(k in 1:length(l)) {                # these are the model rate numerical value, based on parameters optimization
  for(i in 1:length(j)) {              # these are "improbabilities" to shift from parthenogenesis to bisexuality
    
    tmp <- matrix(nrow=1, ncol=3) 
    colnames(tmp) <- c("impro","root_p","param_rate")
    tmp <- data.frame(tmp)
    
    Q=matrix(c(-(l[k]/j[i]),l[k],(l[k]/j[i]),-l[k]),2,2)              #recursively build the matrix
    
    rownames(Q)<-colnames(Q)<-c("B","P")
    trees_subsampled<-sample(trees,size = ntre)
    Object=make.simmap(tree=trees_subsampled,x=trait, Q=Q, nsim = ntre)
    Object=describe.simmap(Object)
    #Object
    #plot(Object,fsize=.25,cex=.5, legend = T)
    root_pt_prob <- Object$ace[1,2]
    #part_time <- mean(Object$times[,2])/mean(Object$times[,3])
    
    
    tmp[1,1] <- j[i]                   # improprobability to shift from parthenogenesis to bisexuality
    tmp[1,2] <- root_pt_prob           # probability of root beeing parthenogenetic
    tmp[1,3] <- l[k]                   # model rate numerical value
    
    overall <- rbind(tmp, overall)
  }
}

################################################################################################### extended dataset stochastic simulations param ####

l=seq(step_l,max_l, by=step_l)         # these are the model rate numerical value, based on parameters optimization
j=seq(0.1,max_j+step_j, by=step_j)     # these are "improbabilities" to shift from parthenogenesis to bisexuality

################################################################################################### extended dataset stochastic simulations second side ####

for(k in 1:length(l)) {                # these are the model rate numerical value, based on parameters optimization
  for(i in 1:length(j)) {              # these are "improbabilities" to shift from parthenogenesis to bisexuality
    
    tmp <- matrix(nrow=1, ncol=3) 
    colnames(tmp) <- c("impro","root_p","param_rate")
    tmp <- data.frame(tmp)
    
    Q=matrix(c(-(l[k]/j[i]),l[k],(l[k]/j[i]),-l[k]),2,2)              #recursively build the matrix
    
    rownames(Q)<-colnames(Q)<-c("B","P")
    trees_subsampled<-sample(trees,size = ntre)
    Object=make.simmap(tree=trees_subsampled,x=trait, Q=Q, nsim = ntre)
    Object=describe.simmap(Object)
    #Object
    #plot(Object,fsize=.25,cex=.5)
    root_pt_prob <- Object$ace[1,2]
    tmp[1,1] <- -j[i]               # improprobability to shift from parthenogenesis to bisexuality
    tmp[1,2] <- root_pt_prob        # probability of root beeing parthenogenetic
    tmp[1,3] <- l[k]                # model rate numerical value
    
    overall <- rbind(tmp, overall)
  }
}

################################################################################################### extended dataset plot ####

overall <- na.omit(overall)

overall$impro <- as.character(overall$impro)
overall$param_rate <- as.character(overall$param_rate)

overall$impro <- as.numeric(overall$impro)
overall$param_rate <- as.numeric(overall$param_rate)

overall[order(overall$root_p, decreasing = TRUE), ]
overall[order(overall$root_p), ]

ggplot(overall, aes(x=impro, y=param_rate, fill=root_p)) +
  geom_tile(color = "white", lwd = .75) + 
  scale_fill_gradient2("p. root", low="lightblue", mid = "gray95", high="orange", midpoint = 0.5, limits = c(.0,1)) +
  labs(x = "relative probability of shifts to bisexuality", y = "rate of model") + coord_flip() +
  theme(axis.title.x=element_blank()) + 
  theme(axis.title.y=element_blank()) + 
  theme(plot.title = element_text(size=16,face="bold")) +
  theme_minimal() + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) + theme(aspect.ratio=1)

ggsave("S3.pdf",plot = last_plot(),
       width = 12, height = 12, dpi = 300)

