# Ancestral state hypothesis - parthenogens underwent fewer changes than bisexual spp

*environiments:* yaml.main

*aim:* infer mutation accumulation in parthenogenetic and gonochoric species pairs

## Mutation accumulation in parthenogenetic and gonochoric species pairs

Mutation accumulation inference in parthenogenetic and gonochoric species pairs - Using a custom R script (Team R Core, 2014), all gene trees previously inferred using amino acid alignments were examined to find instances where the species pair was in the correct relationship to each other. For each correct species pair, the ancestor node was retrieved, and the branch length of the parthenogen and the gonochoric species were collected. Subsequently, we tested that parthenogens accumulated fewer mutations using a paired Wilcoxon test and plotted the mean values in a lolliplot chart using ggplot2 (Wickham 2016). The approach used here considers only instances where gene trees are in accordance with the species tree and allows us not to force a specific topology in the gene trees tree; the latter might be potentially wrong (due to phenomena such as incomplete lineage sorting or introgressions), distort branch lengths inference and eventually the whole analysis (Mendes and Hahn, 2016).

---


[main](https://github.com/MattiaRag/timemaproject/tree/main) /
[exp_des](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/exp_design.md) /
[prel](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/preliminary.md) /
[1](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_1.md) /
[2](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_2.md) /
[3](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_3.md) /
4  

