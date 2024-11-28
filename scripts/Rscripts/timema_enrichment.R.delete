# script for hemiplasy enrichment


setwd("")


########################################################################################### requirements ####


library(topGO)

library(data.table)

library(dplyr)

library(formattable)

library(tidyr)

library(htmltools)

library(webshot)    

library(scales)

library(ggplot2)

library(ggfortify)


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


########################################################################################### parameters ####


pvgo <- 0.05        # pvalue for enrichment

ndsz <- 5     # node size for enrichment

algr <- "classic"    # algorythm for enrichment

onto <- "BP"

min_prt <- 2

min_bsx <- 2

hemiplasy <- 1


########################################################################################### intro ####


fitch <- read.table(file = "fitch_results_aa.txt", sep = "\t")


fitch$V1 <- gsub("loci_","",fitch$V1)

fitch$V1 <- gsub("full homoplasy","",fitch$V1)

fitch$V1 <- gsub("some hemiplasy","",fitch$V1)

fitch$V1 <- gsub("full hemiplasy","",fitch$V1)

fitch$V1 <- gsub(" ","",fitch$V1)


colnames(fitch) <- c("gene","hemiplasy","min_prt","min_bsx","tot_spp")


genesOfInterest <- as.character(subset(fitch, hemiplasy == 1 & 

                                         min_prt > 2 & 

                                         min_bsx > 2)$gene)


geneID2GO <- readMappings(file = "OMA_formatted.txt")


geneUniverse <- names(geneID2GO)


geneList <- factor(as.integer(geneUniverse %in% genesOfInterest))

names(geneList) <- geneUniverse

myGOdata <- new("topGOdata", description="tim", ontology=onto, allGenes=geneList,  annot = annFUN.gene2GO, gene2GO = geneID2GO, nodeSize=ndsz)

test <- runTest(myGOdata, algorithm=algr, statistic="fisher")


table <- GenTable(myGOdata,

                   test = test,

                   orderBy = "test", topNodes=1000)

table <- subset(table, test < pvgo)

table <- table[order(table$test,decreasing = F),]


write.table(table,"enrichment.tsv",  row.names=F, quote=F, sep = " ")


row.names(table) <- NULL


table$color <- -log(as.numeric(table$test))


table$ratio <- table$Significant / table$Expected

table$Significant <- NULL

table$Expected <- NULL

table$Annotated <- NULL

table$ratio <- round(table$ratio,2)


colnames(table) <- c("id","term","p","color","sig/exp")

table[nrow(table) + 1,] = c(" "," ",pvgo,-log(0.01),0)

table[nrow(table) + 1,] = c(" "," ",0,Inf,0)


plot <- formattable(table, list(color = FALSE, Expected = FALSE,

                                `id` = formatter("span", style = ~ style(color = "black",font.weight = "bold")), 

                                `p`= color_tile("orange", "white"), 

                                `sig/exp`= color_bar("orange")),

                    table.attr = 'style="font-size: 20px; font-family: Arial";\"')

save.image(plot)

save.image()

save(plot, file=Desktop)



export_formattable(plot,"test.png")


