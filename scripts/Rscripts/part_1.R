#!/usr/bin/env Rscript

################################################################################################### requirements ###

args = commandArgs(trailingOnly=TRUE)

suppressMessages(library(data.table))
suppressMessages(library(dplyr))
suppressMessages(library(tidyr))
suppressMessages(library(stringr))
suppressMessages(library(ggplot2))
suppressMessages(library(ggrepel))

################################################################################################### simulation ###

aa <- read.table(file = "heist_aa_summary.tsv", sep = "\t", header = T)
nu <- read.table(file = "heist_nu_summary.tsv", sep = "\t", header = T)

aa$type <- "aa"
nu$type <- "nu"

aa <- aa %>% separate_wider_delim(File, delim = "_heist_", names = c("sp", "rate"))
aa <- melt(setDT(aa), id.vars = c("sp","type","rate"), variable.name = "state")
aa$rate <- gsub("_summary.txt", "", aa$rate)

nu <- nu %>% separate_wider_delim(File, delim = "_heist_", names = c("sp", "rate"))
nu <- melt(setDT(nu), id.vars = c("sp","type","rate"), variable.name = "state")
nu$rate <- gsub("_summary.txt", "", nu$rate)

################################################################################################### empirical aa ###

genes_aa <-  read.table("fitch_results_aa.txt", sep = "\t", header = F)
colnames(genes_aa) <-  c("gene","hemiplasy_score", "prt", "bsx","total")
genes_aa$gene <- gsub("loci_", "", genes_aa$gene)
genes_aa$result <-  str_split_fixed(genes_aa$gene, " ", 2)[,2]
genes_aa$gene <-  str_split_fixed(genes_aa$gene, " ", 2)[,1]

gene_trees_aa <- read.table(file = "gene_trees_aa.txt", sep ="\t")
gene_trees_aa$V1 <- gsub("loci_", "", gene_trees_aa$V1)
gene_trees_aa$V2 <- gsub("\"", "", gene_trees_aa$V2)  
  
  # Loop through the dataframe and filter based on the condition
genes_brfilter_aa <- sapply(1:nrow(gene_trees_aa), function(i) {
    # Extract the tree
    tree <- read.tree(text = gene_trees_aa$V2[[i]])
    # Calculate the proportion of branch lengths greater than zero
    prop_greater_than_zero <- mean(tree$edge.length >= 0.000001)
    # If more than 50% of branch lengths are greater than zero, return the tree name
    if (prop_greater_than_zero >= 1) {
      return(gene_trees_aa$V1[i])
    } else {
      return(NA)  # Return NA if the condition is not met
    }
  })
# Remove NA values from the result
genes_brfilter_aa <- genes_brfilter_aa[!is.na(genes_brfilter_aa)] 
  
genes_aa <- subset(genes_aa, genes_aa$gene %in% genes_brfilter_aa)

genes_aa_min05 <- subset(genes_aa, prt >= 4 & bsx >= 4)
genes_aa_min10 <- subset(genes_aa, total == 10)

#enrichment <- subset(genes_aa_min05,  result != "full hemiplasy " & prt >= 4 & bsx >= 4 & hemiplasy_score < 3)$gene
#genes_aa_min05$result[genes_aa_min05$gene %in% enrichment] <- "Enrichment"

table_aa_min05 <- as.data.frame(table(genes_aa_min05$result))
table_aa_min05$sp <- "min_5sp"
table_aa_min10 <- as.data.frame(table(genes_aa_min10$result))
table_aa_min10$sp <- "min_10sp"

table_aa <- rbind(table_aa_min05,table_aa_min10)
table_aa$type <- "aa"

colnames(table_aa) <- c("state","value","sp","type")
table_aa$rate <- "gene trees"
table_aa$state <- gsub("full homoplasy ", "Full_homoplasy", table_aa$state)
table_aa$state <- gsub("full hemiplasy ", "Full_hemiplasy", table_aa$state)
table_aa$state <- gsub("some hemiplasy ", "Some_hemiplasy", table_aa$state)

################################################################################################### empirical nu ###

genes_nu <-  read.table("fitch_results_nu.txt", sep = "\t", header = F)
colnames(genes_nu) <-  c("gene","hemiplasy_score", "prt", "bsx","total")
genes_nu$gene <- gsub("loci_", "", genes_nu$gene)
genes_nu$result <-  str_split_fixed(genes_nu$gene, " ", 2)[,2]
genes_nu$gene <-  str_split_fixed(genes_nu$gene, " ", 2)[,1]

gene_trees_nu <- read.table(file = "gene_trees_nu.txt", sep ="\t")
gene_trees_nu$V1 <- gsub("loci_", "", gene_trees_nu$V1)
gene_trees_nu$V2 <- gsub("\"", "", gene_trees_nu$V2)  

# Loop through the dataframe and filter based on the condition
genes_brfilter_nu <- sapply(1:nrow(gene_trees_nu), function(i) {
  # Extract the tree
  tree <- read.tree(text = gene_trees_nu$V2[[i]])
  # Calculate the proportion of branch lengths greater than zero
  prop_greater_than_zero <- mean(tree$edge.length >= 0.000001)
  # If more than 50% of branch lengths are greater than zero, return the tree name
  if (prop_greater_than_zero >= 1) {
    return(gene_trees_nu$V1[i])
  } else {
    return(NA)  # Return NA if the condition is not met
  }
})
# Remove NA values from the result
genes_brfilter_nu <- genes_brfilter_nu[!is.na(genes_brfilter_nu)] 

genes_nu <- subset(genes_nu, genes_nu$gene %in% genes_brfilter_nu)

genes_nu_min05 <- subset(genes_nu, prt >= 4 & bsx >= 4)
genes_nu_min10 <- subset(genes_nu, total == 10)

table_nu_min05 <- as.data.frame(table(genes_nu_min05$result))
table_nu_min05$sp <- "min_5sp"
table_nu_min10 <- as.data.frame(table(genes_nu_min10$result))
table_nu_min10$sp <- "min_10sp"

table_nu <- rbind(table_nu_min05,table_nu_min10)
table_nu$type <- "nu"

colnames(table_nu) <- c("state","value","sp","type")
table_nu$rate <- "gene trees"
table_nu$state <- gsub("full homoplasy ", "Full_homoplasy", table_nu$state)
table_nu$state <- gsub("full hemiplasy ", "Full_hemiplasy", table_nu$state)
table_nu$state <- gsub("some hemiplasy ", "Some_hemiplasy", table_nu$state)

################################################################################################### plot ###

tot <- rbind(aa,table_aa,nu,table_nu,fill=TRUE)

tot <- subset(tot, value != 0)

#tot$state <- factor(tot$state, levels = c("Full_hemiplasy","Enrichment","Some_hemiplasy","Full_homoplasy"))
tot$state <- factor(tot$state, levels = c("Full_hemiplasy","Some_hemiplasy","Full_homoplasy"))

ggplot(tot, aes(fill=state, y=value, x=rate)) + 
  geom_bar(position="fill", stat="identity", width=.75) + 
  geom_text(aes(x = rate, label = value, group = state), position = position_fill(vjust = .5), colour = "black", fontface = "plain") + 
  coord_flip() + theme_classic() +
  facet_wrap(type~sp, nrow=2) + geom_hline(aes(yintercept= .5), colour='black', alpha=.5, linetype="dashed") +
  theme(strip.background = element_rect(fill = "white", colour = "black", size = .5)) +
  #theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + labs(x = "" ) + labs(y = "") + scale_fill_manual(values=c("#f4d06f","orange","#ffbf69","lightblue")) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + labs(x = "" ) + labs(y = "") + scale_fill_manual(values=c("orange","#ffbf69","lightblue")) +
  theme(strip.background = element_rect(color = "white"),strip.placement = "inside")

ggsave("S4.pdf",plot = last_plot(),
       width = 12, height = 6, dpi = 300)

################################################################################################### plot ###

tot <- rbind(aa,table_aa,fill=TRUE)

tot <- subset(tot, sp == "min_5sp")
tot <- subset(tot, value != 0)

#tot$state <- factor(tot$state, levels = c("Full_hemiplasy","Enrichment","Some_hemiplasy","Full_homoplasy"))
tot$state <- factor(tot$state, levels = c("Full_hemiplasy","Some_hemiplasy","Full_homoplasy"))
ggplot(tot, aes(fill=state, y=value, label=value, x=rate)) + 
  geom_bar(position="fill", stat="identity", width=.75) + 
  geom_text(aes(x = rate, label = value, group = state), position = position_fill(vjust = .5), colour = "black", fontface = "plain") + 
  theme_classic() +
  geom_hline(aes(yintercept= .5), colour='black', alpha=.5, linetype="dashed") +
  theme(strip.background = element_rect(fill = "white", colour = "black", size = .5)) +
  #theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + labs(x = "" ) + labs(y = "") + scale_fill_manual(values=c("#f4d06f","orange","#ffbf69","lightblue")) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + labs(x = "" ) + labs(y = "") + scale_fill_manual(values=c("orange","#ffbf69","lightblue")) 

ggsave("2A.pdf",plot = last_plot(),
       width = 6, height = 6, dpi = 300)
