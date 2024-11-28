# Ancestral state hypothesis - parthenogens underwent fewer changes than bisexual spp

*environiments:* yaml.main

*aim:* compare mutation accumulation rates between parthenogenetic and gonochoric species pairs

## Mutation accumulation in parthenogenetic and gonochoric species pairs

Using a custom [R script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/Rscripts/part_4.R), all gene trees previously inferred from amino acid alignments are analyzed to identify correct species pairs (where parthenogenetic and gonochoric species are in the expected relationship). For each valid pair:

* Gene Trees Validation: gene trees are pruned to exclude tips with branch lengths exceeding 10% of the total tree length, ensuring data quality.
* Branch Length Collection: the branch lengths from both parthenogenetic and gonochoric species are extracted at their most recent common ancestor (MRCA).
* Statistical Test: a paired Wilcoxon test is performed to compare mutation accumulation between the two groups.

The script accepts as input [fitch_asr_input_aa.txt](https://github.com/MattiaRag/timemaproject/tree/main/intermediate_files/fitch_asr_inputs), and [Fig. 1B](https://github.com/MattiaRag/timemaproject/blob/main/pictures/1B.pdf) is produced as output.



---


[main](https://github.com/MattiaRag/timemaproject/tree/main) /
[exp_des](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/exp_design.md) /
[prel](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/preliminary.md) /
[1](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_1.md) /
[2](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_2.md) /
[3](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_3.md) /
4  

