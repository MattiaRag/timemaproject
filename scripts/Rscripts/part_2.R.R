
#!/usr/bin/env Rscript

################################################################################################### requirements ####

args = commandArgs(trailingOnly=TRUE)

suppressMessages(library(topGO))
suppressMessages(library(data.table))
suppressMessages(library(dplyr))
suppressMessages(library(formattable))
suppressMessages(library(tidyr))
suppressMessages(library(stringr))
suppressMessages(library(htmltools))
suppressMessages(library(webshot)    )
suppressMessages(library(VennDiagram))
suppressMessages(library(RColorBrewer))
suppressMessages(library(GO.db))
suppressMessages(library(ggplot2))
suppressMessages(library(ape))

export_formattable <- function(f, file, width = "100%", height = NULL, 
                               background = "white", delay = 0.2)
{
  w <- as.htmlwidget(f, width = width, height = height)
  path <- html_print(w, background = background, viewer = NULL)
  url <- paste0("file:///", gsub("\\\\", "/", normalizePath(path)))
  webshot(url,
          file = file,
          selector = ".formattable_widget",
          delay = delay)
}

################################################################################################### input ####

genes_aa <-  read.table("fitch_results_aa.txt", sep = "\t", header = F)
colnames(genes_aa) <-  c("gene","hemiplasy_score", "prt", "bsx","total")
genes_aa$gene <- gsub("loci_", "", genes_aa$gene)
genes_aa$result <-  str_split_fixed(genes_aa$gene, " ", 2)[,2]
genes_aa$gene <-  str_split_fixed(genes_aa$gene, " ", 2)[,1]

genes_nu <-  read.table("fitch_results_nu.txt", sep = "\t", header = F)
colnames(genes_nu) <-  c("gene","hemiplasy_score", "prt", "bsx","total")
genes_nu$gene <- gsub("loci_", "", genes_nu$gene)
genes_nu$result <-  str_split_fixed(genes_nu$gene, " ", 2)[,2]
genes_nu$gene <-  str_split_fixed(genes_nu$gene, " ", 2)[,1]

gene_trees_aa <- read.table(file = "gene_trees_aa.txt", sep ="\t")
gene_trees_aa$V1 <- gsub("loci_", "", gene_trees_aa$V1)
gene_trees_aa$V2 <- gsub("\"", "", gene_trees_aa$V2)

gene_trees_nu <- read.table(file = "gene_trees_nu.txt", sep ="\t")
gene_trees_nu$V1 <- gsub("loci_", "", gene_trees_nu$V1)
gene_trees_nu$V2 <- gsub("\"", "", gene_trees_nu$V2)

sp_treshold <- 4         # minimum number of bsx and prt species to consider a gene
zero_proportion <- 1     # minimum proportion of species having non-zero branchlenghts
hscore_max <- 2          # maximum number of indipendent evolutions of prt
ALGORTHM <- "weight01"   # algorithm for enrichment

################################################################################################### enrichment backgorund for amino acids-based analyses ####

# Loop through the dataframe and filter based on the condition
tree_names_brfiltered_aa <- sapply(1:nrow(gene_trees_aa), function(i) {
  # Extract the tree
  tree <- read.tree(text = gene_trees_aa$V2[[i]])
  # Calculate the proportion of branch lengths greater than zero
  prop_greater_than_zero <- mean(tree$edge.length >= 0.000001)
  # If more than 50% of branch lengths are greater than zero, return the tree name
  if (prop_greater_than_zero >= zero_proportion) {
    return(gene_trees_aa$V1[i])
  } else {
    return(NA)  # Return NA if the condition is not met
  }
})
# Remove NA values from the result
tree_names_brfiltered_aa <- tree_names_brfiltered_aa[!is.na(tree_names_brfiltered_aa)]

genes_min_sp <- subset(genes_aa, prt >= sp_treshold & bsx >= sp_treshold)

background_subset <- intersect(genes_min_sp$gene,tree_names_brfiltered_aa)

original_universe <- read.table("OMA_formatted.txt", sep = "\t")
new_universe <- subset(original_universe, original_universe$V1 %in% background_subset)
write.table(new_universe, "new_universe", row.names = F, col.names = F, quote = F, sep = "\t")
geneID2GO <- readMappings(file = "new_universe")
geneUniverse <- names(geneID2GO)

################################################################################################### full hemiplasy aa ####

genes_full_aa <- subset(genes_aa, result == "full hemiplasy " & prt >= sp_treshold & bsx >= sp_treshold)
genes_full_aa$gene <- as.numeric(genes_full_aa$gene)
genes_full_aa <- genes_full_aa[order(genes_full_aa$gene), ]

gene_trees_full_aa <- gene_trees_aa[gene_trees_aa$V1 %in% genes_full_aa$gene, ]

# Loop through the dataframe and filter based on the condition
tree_names_brfiltered_full_aa <- sapply(1:nrow(gene_trees_full_aa), function(i) {
  # Extract the tree
  tree <- read.tree(text = gene_trees_full_aa$V2[[i]])
  # Calculate the proportion of branch lengths greater than zero
  prop_greater_than_zero <- mean(tree$edge.length >= 0.000001)
  # If more than 50% of branch lengths are greater than zero, return the tree name
  if (prop_greater_than_zero >= zero_proportion) {
    return(gene_trees_full_aa$V1[i])
  } else {
    return(NA)  # Return NA if the condition is not met
  }
})
# Remove NA values from the result
genes_full_aa <- tree_names_brfiltered_full_aa[!is.na(tree_names_brfiltered_full_aa)]

genes_full_aa <- genes_aa[genes_aa$gene %in% genes_full_aa, ]
write.table(genes_full_aa, "hemiplasy_full_genes_aa.tsv", sep="\t")

################################################################################################### some hemiplasy aa ####

genes_some_aa <-  subset(genes_aa, result == "some hemiplasy " & prt >= sp_treshold & bsx >= sp_treshold & hemiplasy_score <= hscore_max )
genes_some_aa$gene <- as.numeric(genes_some_aa$gene)
genes_some_aa <- genes_some_aa[order(genes_some_aa$gene), ]

gene_trees_some_aa <- gene_trees_aa[gene_trees_aa$V1 %in% genes_some_aa$gene, ]

# Loop through the dataframe and filter based on the condition
tree_names_brfiltered_some_aa <- sapply(1:nrow(gene_trees_some_aa), function(i) {
  # Extract the tree
  tree <- read.tree(text = gene_trees_some_aa$V2[[i]])
  # Calculate the proportion of branch lengths greater than zero
  prop_greater_than_zero <- mean(tree$edge.length >= 0.000001)
  # If more than 50% of branch lengths are greater than zero, return the tree name
  if (prop_greater_than_zero >= zero_proportion) {
    return(gene_trees_some_aa$V1[i])
  } else {
    return(NA)  # Return NA if the condition is not met
  }
})
# Remove NA values from the result
genes_some_aa <- tree_names_brfiltered_some_aa[!is.na(tree_names_brfiltered_some_aa)]

genes_some_aa <- genes_aa[genes_aa$gene %in% genes_some_aa, ]
write.table(genes_some_aa, "hemiplasy_some_genes_aa.tsv", sep="\t")

################################################################################################### full hemiplasy nu ####

genes_full_nu <- subset(genes_nu, result == "full hemiplasy " & prt >= sp_treshold & bsx >= sp_treshold)
genes_full_nu$gene <- as.numeric(genes_full_nu$gene)
genes_full_nu <- genes_full_nu[order(genes_full_nu$gene), ]

gene_trees_full_nu <- gene_trees_nu[gene_trees_nu$V1 %in% genes_full_nu$gene, ]

# Loop through the dataframe and filter based on the condition
tree_names_brfiltered_full_nu <- sapply(1:nrow(gene_trees_full_nu), function(i) {
  # Extract the tree
  tree <- read.tree(text = gene_trees_full_nu$V2[[i]])
  # Calculate the proportion of branch lengths greater than zero
  prop_greater_than_zero <- mean(tree$edge.length >= 0.000001)
  # If more than 50% of branch lengths are greater than zero, return the tree name
  if (prop_greater_than_zero >= zero_proportion) {
    return(gene_trees_full_nu$V1[i])
  } else {
    return(NA)  # Return NA if the condition is not met
  }
})
# Remove NA values from the result
genes_full_nu <- tree_names_brfiltered_full_nu[!is.na(tree_names_brfiltered_full_nu)]

genes_full_nu <- genes_nu[genes_nu$gene %in% genes_full_nu, ]
write.table(genes_full_nu, "hemiplasy_full_genes_nu.tsv", sep="\t")

################################################################################################### some hemiplasy nu ####

genes_some_nu <- subset(genes_nu, result == "some hemiplasy " & prt >= sp_treshold & bsx >= sp_treshold & hemiplasy_score <= hscore_max )
genes_some_nu$gene <- as.numeric(genes_some_nu$gene)
genes_some_nu <- genes_some_nu[order(genes_some_nu$gene), ]

gene_trees_some_nu <- gene_trees_nu[gene_trees_nu$V1 %in% genes_some_nu$gene, ]

# Loop through the dataframe and filter based on the condition
tree_names_brfiltered_some_nu <- sapply(1:nrow(gene_trees_some_nu), function(i) {
  # Extract the tree
  tree <- read.tree(text = gene_trees_some_nu$V2[[i]])
  # Calculate the proportion of branch lengths greater than zero
  prop_greater_than_zero <- mean(tree$edge.length >= 0.000001)
  # If more than 50% of branch lengths are greater than zero, return the tree name
  if (prop_greater_than_zero >= zero_proportion) {
    return(gene_trees_some_nu$V1[i])
  } else {
    return(NA)  # Return NA if the condition is not met
  }
})
# Remove NA values from the result
genes_some_nu <- tree_names_brfiltered_some_nu[!is.na(tree_names_brfiltered_some_nu)]

genes_some_nu <- genes_nu[genes_nu$gene %in% genes_some_nu, ]
write.table(genes_some_nu, "hemiplasy_some_genes_nu.tsv", sep="\t")

################################################################################################### hemiplasy intersect ####

genes_hem_aa <- c(genes_some_aa$gene,genes_full_aa$gene)
write.table(genes_hem_aa, "hemiplasy_aa_genes.tsv", sep="\t")

genes_hem_nu <- c(genes_some_nu$gene,genes_full_nu$gene)
write.table(genes_hem_nu, "hemiplasy_nu_genes.tsv", sep="\t")

genes_full <- intersect(genes_full_aa$gene,genes_full_nu$gene)
write.table(genes_full, "hemiplasy_full_genes.tsv", sep="\t")

genes_some <- intersect(genes_some_aa$gene,genes_some_nu$gene)
write.table(genes_some, "hemiplasy_some_genes.tsv", sep="\t")

################################################################################################### enrichment aa ####

genes_of_interest <- genes_hem_aa
  
genes_of_interest <- factor(as.integer(geneUniverse %in% genes_of_interest))
names(genes_of_interest) <- geneUniverse
myGOdata <- new("topGOdata", description="", ontology="BP", allGenes=genes_of_interest,  annot = annFUN.gene2GO, gene2GO = geneID2GO, nodeSize=10)
test <- runTest(myGOdata, algorithm=ALGORTHM, statistic="fisher")
allRes <- GenTable(myGOdata,
                        test = test,
                        orderBy = "test", topNodes=1000)

allRes <- subset(allRes, test < 0.05 & Significant >= 5)

write.table(allRes, file = "TabS4.tsv", sep = "\t", row.names = FALSE, quote = FALSE)

allRes <- head(allRes,20)

row.names(allRes) <- NULL
allRes$ratio <- round(allRes$Significant / allRes$Expected,2)
allRes <- allRes[order(allRes$test,decreasing = F),]

allRes$color <- -log(as.numeric(allRes$test))

allRes <- head(allRes,25)

allRes$Annotated <- NULL
allRes$Expected <- NULL
allRes$ratio <- NULL
row.names(allRes) <- NULL

totable <- formattable(allRes, list(color = FALSE, Expected = FALSE,
                                     `GO.ID` = formatter("span", style = ~ style(color = "grey",font.weight = "bold")), 
                                     #`test`= color_tile("orange", "white"), 
                                     `Significant`= color_bar("orange")),
                        table.attr = 'style="font-size: 20px; font-family: Arial";\"')

export_formattable(totable, "2B.png")

################################################################################################### extract target genes ####

allgenes <- genesInTerm(myGOdata, whichGO="GO:0031536")

intersect(as.vector(allgenes)[[1]],as.vector(genes_hem_aa))
