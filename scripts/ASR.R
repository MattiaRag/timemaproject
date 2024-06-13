library(ape)
library(geiger)
library(phytools)
library(ggplot2)
library(latticeExtra)
library(gridExtra)

##################################################################################### requirements ###########################################

sampled.trees=read.tree("Random_Trees_renamed.nwk")                       #import a distribution of trees
consensus.tree=read.nexus("Consensus_combined_renamed.contree")           #import the "best" tree
data=read.table("trait_2_states.txt",header=T,row.names = 1, sep="\t")    #import binary data
chk<-name.check(consensus.tree,data)
tree.pruned<-drop.tip(consensus.tree,chk$tree_not_data)
pruned.trees<-lapply(sampled.trees,drop.tip,tip=chk$tree_not_data)
class(pruned.trees)<-"multiPhylo"
data.pruned<-data[!(rownames(data)%in%chk$data_not_tree),,drop=FALSE]
wings<-setNames(as.factor(data.pruned[,"trait"]),rownames(data.pruned))

#################################################################################### 100 stochastic simulations on "best" tree ###############

l=seq(0.001, 0.02, by=0.001)        #these are the model rate numerical value, vaguely based on other analyses parameters optimization
j=seq(10,500, by=10)                #these are "improbabilities", from 1:10 to 1:500

length(l)
length(j)

mean_transitions=matrix(nrow=0, ncol=6) 
colnames(mean_transitions) <- c("q01","q10","consistency","gains","losses","improbability")
mean_transitions=data.frame(mean_transitions)

mean_transitions_tmp_100sim=matrix(nrow=1, ncol=6) 
colnames(mean_transitions_tmp_100sim) <- c("q01","q10","consistency","gains","losses","improbability")
mean_transitions_tmp_100sim=data.frame(mean_transitions_tmp_100sim)

for(k in 1:20){
  for(i in 1:50) {
    
    Q=matrix(c(-(l[k]/j[i]),l[k],(l[k]/j[i]),-l[k]),2,2)              #recursively build the matrix
    rownames(Q)<-colnames(Q)<-c(0,1)
    
    Object=make.simmap(tree=tree.pruned,x=wings, Q=Q,nsim=100)
    Object=describe.simmap(Object)
    mean_transitions_tmp_100sim[1,1]=l[k]/j[i]
    mean_transitions_tmp_100sim[1,2]=l[k]

    consistency=length(Object$count[,2][Object$count[,2] >=1])        #extract "consistency" or how frequently trait change happens
    
    if (consistency >= length(Object$count[,2])) {                    
      mean_transitions_tmp_100sim[1,3]=1
    } else if (consistency > 0 && consistency < length(Object$count[,2])) {
      mean_transitions_tmp_100sim[1,3]=consistency/100
    } else {
      mean_transitions_tmp_100sim[1,3]=0
    }
    
    mean_transitions_tmp_100sim[1,4]=mean(Object$count[,2])
    mean_transitions_tmp_100sim[1,5]=mean(Object$count[,3])
    mean_transitions_tmp_100sim[1,6]=j[i]
    mean_transitions_100sim <- rbind(mean_transitions, mean_transitions_tmp_100sim)
  }
}

save.image(file = "mech.Rdata")

consistency <- ggplot(mean_transitions_100sim, aes(x=q10, y=improbability, fill=consistency)) + 
               scale_fill_gradient(low="darkmagenta", high="goldenrod1") +
               geom_tile(data = subset(mean_transitions_100sim, consistency >= 1), fill = "goldenrod1") + 
               geom_tile(data = subset(mean_transitions_100sim, consistency < 1 & consistency > 0)) +
               geom_tile(data = subset(mean_transitions_100sim, consistency == 0), fill = "white") +
               labs(x = "wings loss rate", y = "improbability of reacquisition") + coord_flip() + theme_minimal() + 
               theme(axis.title.x=element_blank()) + 
               theme(axis.title.y=element_blank()) + 
               theme(plot.title = element_text(size=16,face="bold")) +
               theme(axis.text=element_text(size=15), axis.title=element_text(size=0,face="bold"))

loss <- ggplot(mean_transitions_100sim, aes(x=q10, y=improbability, fill=losses, size=4)) + geom_tile() +
        scale_fill_gradient(low="white", high="darkmagenta") +
        labs(x = "wings loss rate", y = "improbability of reacquisition") + coord_flip() + theme_minimal()  + 
        theme(axis.title.x=element_blank()) + 
        theme(axis.title.y=element_blank()) + 
        theme(plot.title = element_text(size=16,face="bold")) +
        theme(axis.text=element_text(size=15), axis.title=element_text(size=0,face="bold"))

gain <-  ggplot(mean_transitions_100sim, aes(x=q10, y=improbability, fill=gains, size=4)) + geom_tile() +
         scale_fill_gradient2(low="darkmagenta", mid="white", high="goldenrod1") +
         labs(x = "wings loss rate", y = "improbability of reacquisition") + coord_flip() + theme_minimal()  + 
         theme(axis.title.x=element_blank()) + 
         theme(axis.title.y=element_blank()) + 
         theme(plot.title = element_text(size=16,face="bold")) +
         theme(axis.text=element_text(size=15), axis.title=element_text(size=0,face="bold"))
  
grid.arrange(consistency, gain, loss, nrow=3)

#################################################################################### 100 stochastic simulations on 100 trees ###############

l=seq(0.001, 0.02, by=0.001)        #these are the model rate numerical value, vaguely based on other analyses parameters optimization
j=seq(10,500, by=10)                #these are "improbabilities", from 1:10 to 1:500

length(l)
length(j)

mean_transitions_100trees=matrix(nrow=0, ncol=6) 
colnames(mean_transitions_100trees) <- c("q01","q10","consistency","gains","losses","improbability")
mean_transitions_100trees=data.frame(mean_transitions_100trees)

mean_transitions_tmp_100trees=matrix(nrow=1, ncol=6) 
colnames(mean_transitions_tmp_100trees) <- c("q01","q10","consistency","gains","losses","improbability")
mean_transitions_tmp_100trees=data.frame(mean_transitions_tmp_100trees)

for(k in 1:20){
  for(i in 1:50) {
    
    Q=matrix(c(-(l[k]/j[i]),l[k],(l[k]/j[i]),-l[k]),2,2)              #recursively build the matrix
    rownames(Q)<-colnames(Q)<-c(0,1)
    
    trees_subsampled<-sample(pruned.trees,size=100)
    
    Object=make.simmap(tree=trees_subsampled,x=wings, Q=Q,nsim=1)
    Object=describe.simmap(Object)
    mean_transitions_tmp_100trees[1,1]=l[k]/j[i]
    mean_transitions_tmp_100trees[1,2]=l[k]
    
    consistency=length(Object$count[,2][Object$count[,2] >=1])        #extract "consistency" or how frequently trait change happens
    
    if (consistency >= length(Object$count[,2])) {
      mean_transitions_tmp_100trees[1,3]=1
    } else if (consistency > 0 && consistency < length(Object$count[,2])) {
      mean_transitions_tmp_100trees[1,3]=consistency/100
    } else {
      mean_transitions_tmp_100trees[1,3]=0
    }
    
    mean_transitions_tmp_100trees[1,4]=mean(Object$count[,2])
    mean_transitions_tmp_100trees[1,5]=mean(Object$count[,3])
    mean_transitions_tmp_100trees[1,6]=j[i]
    mean_transitions_100trees <- rbind(mean_transitions_100trees, mean_transitions_tmp_100trees)
  }
}

save.image(file = "mech.Rdata")

consistency_100trees <- ggplot(mean_transitions_100trees, aes(x=q10, y=improbability, fill=consistency)) + 
  scale_fill_gradient(low="darkmagenta", high="goldenrod1") +
  geom_tile(data = subset(mean_transitions_100trees, consistency >= 1), fill = "goldenrod1") + 
  geom_tile(data = subset(mean_transitions_100trees, consistency < 1 & consistency > 0)) +
  geom_tile(data = subset(mean_transitions_100trees, consistency == 0), fill = "white") +
  labs(x = "wings loss rate", y = "improbability of reacquisition") + coord_flip() + theme_minimal() + 
  theme(axis.title.x=element_blank()) + 
  theme(axis.title.y=element_blank()) + 
  theme(plot.title = element_text(size=16,face="bold")) +
  theme(axis.text=element_text(size=15), axis.title=element_text(size=0,face="bold"))

loss_100trees <- ggplot(mean_transitions_100trees, aes(x=q10, y=improbability, fill=losses, size=4)) + geom_tile() +
  scale_fill_gradient(low="white", high="darkmagenta") +
  labs(x = "wings loss rate", y = "improbability of reacquisition") + coord_flip() + theme_minimal()  + 
  theme(axis.title.x=element_blank()) + 
  theme(axis.title.y=element_blank()) + 
  theme(plot.title = element_text(size=16,face="bold")) +
  theme(axis.text=element_text(size=15), axis.title=element_text(size=0,face="bold"))

gain_100trees <-  ggplot(mean_transitions_100trees, aes(x=q10, y=improbability, fill=gains, size=4)) + geom_tile() +
  scale_fill_gradient2(low="darkmagenta", mid="white", high="goldenrod1") +
  labs(x = "wings loss rate", y = "improbability of reacquisition") + coord_flip() + theme_minimal()  + 
  theme(axis.title.x=element_blank()) + 
  theme(axis.title.y=element_blank()) + 
  theme(plot.title = element_text(size=16,face="bold")) +
  theme(axis.text=element_text(size=15), axis.title=element_text(size=0,face="bold"))

grid.arrange(consistency_100trees, gain_100trees, loss_100trees, nrow=3)

############################################################################################################## f  #######################

#40x22

grid.arrange(consistency, consistency_100trees,
            gain, gain_100trees,
            loss, loss_100trees,
            ncol=2, nrow=3)