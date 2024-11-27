#!/usr/bin/env Rscript

################################################################################################### requirements ###

args = commandArgs(trailingOnly=TRUE)

suppressMessages(library(phytools))
suppressMessages(library(phangorn))
suppressMessages(library(ggplot2))
suppressMessages(library(tidyr))
suppressMessages(library(ggplot2))
suppressMessages(library(dplyr))

################################################################################################### calculations ###

parthenogens=c("TDI","TSI","TMS","TGE","TTE")
bisexualsspp=c("TPS","TCM","TCE","TPA","TBI")
               
#              
             
table_genetrees <- read.table(file = "asr_input_aa.txt", sep = "\t")              #import the trees

edge.lengths_pt <- ""
edge.lengths_bs <- ""
sp_pt <- ""
sp_bs <- ""
gene <- ""

for (i in 1:dim(table_genetrees)[1]) {
  
  tree <-  table_genetrees$V2[i]
  tree <- read.newick(text=tree)

  to_prune <- ""
  
  for (x in 1:length(tree$tip.label)) {
    if (tree$edge.length[sapply(1:length(tree$tip.label),function(x,y) which (y==x),y=tree$edge[,2])][x] > (sum(tree$edge.length) * 0.1)) {
      to_prune <- c(to_prune,tree$tip.label[x])
    }
  }
  
  for (i in 1:length(parthenogens)) {
    if (parthenogens[i] %in% tree$tip.label & ! (parthenogens[i] %in% to_prune)) {
      st <- getSisters(tree, parthenogens[i], mode="label")$tips
      if (!is.null(st)) {
        if (st == bisexualsspp[i]) {
          nodes_pt <- sapply(parthenogens[i],function(x,y) which(y==x),y=tree$tip.label)
          edge.lengths_pt <- c(edge.lengths_pt,unname(setNames(tree$edge.length[sapply(nodes_pt,function(x,y) which(y==x),y=tree$edge[,2])],names(nodes_pt))))
          nodes_bs <- sapply(bisexualsspp[i],function(x,y) which(y==x),y=tree$tip.label)
          edge.lengths_bs <- c(edge.lengths_bs,unname(setNames(tree$edge.length[sapply(nodes_bs,function(x,y) which(y==x),y=tree$edge[,2])],names(nodes_bs))))
          sp_pt <- c(sp_pt,parthenogens[i])
          sp_bs <- c(sp_bs,bisexualsspp[i])
          gene <- c(gene,table_genetrees$V1[i])
        }
      }
    }
  }
}

df <- data.frame(pt=as.numeric(edge.lengths_pt), bs=as.numeric(edge.lengths_bs), 
                 sp_pt=sp_pt, sp_bs=sp_bs,
                 gene=gene)

df <- na.omit(df)

summary <- df %>% group_by(sp_pt) %>% reframe(mean_pt = median(pt), mean_bs = median(bs))

pval <- df %>% group_by(sp_pt) %>% reframe(p = wilcox.test(pt, bs, alternative = "less", paired = T)$p.value)
pval$pos <- summary$mean_pt+summary$mean_bs/2
pval$p <- round(as.numeric(pval$p))

################################################################################################### plot ###

summary$sp_pt <- factor(summary$sp_pt, levels=c("TTE", "TGE", "TMS", "TSI", "TDI"))

p <- ggplot(summary) +
  geom_segment( aes(x=sp_pt, y=mean_pt, yend=mean_bs), color="grey", size = 10, alpha = .25) +
  #geom_rect(ymin = mean(summary$mean_bs)-sd(summary$mean_bs), 
  #         ymax = mean(summary$mean_bs)+sd(summary$mean_bs),
  #         xmin = 2000, xmax = 000, fill = "lightblue", alpha = .01) +
  geom_hline(yintercept = mean(summary$mean_bs), linetype = "dashed", size = 1, alpha = .8, color = "lightblue") +
  #geom_rect(ymin = mean(summary$mean_pt)-sd(summary$mean_pt), 
  #         ymax = mean(summary$mean_pt)+sd(summary$mean_pt),
  #         xmin = 2000, xmax = 000, fill = "orange", alpha = .01) +
  geom_hline(yintercept = mean(summary$mean_pt), linetype = "dashed", size = 1, alpha = .8, color = "orange") +
  geom_point( aes(x=sp_pt, y=mean_bs), color="lightblue", size=10 ) +
  geom_point( aes(x=sp_pt, y=mean_pt), color="orange", size=10 ) +
  coord_flip() +
  xlab("") +
  ylab("Value of Y") + theme_classic() + 
  labs(x = "", y = "mean branchlength since MRCA") + coord_flip()

p + geom_text(data = pval,
              aes(label = paste("p = ",p), x = sp_pt, y = 0.009),
              color = "black",
              size = 2.5)

ggsave("1B.pdf",plot = last_plot(),
       width = 6, height = 3, dpi = 300)
