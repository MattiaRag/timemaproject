# Ancestral state hypothesis - impact of evolutionary model assumption


*environiments:* yaml.main 


*aim:* infer ultrametric trees with BEAST2 / infer the Ancestral State Recostruction (ASR) 


## Infer ultrametric trees with BEAST2

Bayesian Inference was performed on two datasets: a reduced dataset where all 15 known *Timema* species were represented by a single sequence and an extensive dataset encompassing over one hundred specimens. Both datasets consisted of mitochondrial COI sequences, as they are the only comparable sequence data available for all *Timema* species. Both datasets also included 14 species of Euphasmatodea (the sister clade of Timematodea) and two outgroup species (Embiopterans).
Alignment, trimming, and removal of poorly aligned regions were conducted on the extensive dataset first. From this, a single representative sequence per species was selected to create the reduced dataset, which included also all euphasmatodeans and outgroup species. The sequences can be downloaded from [NCBI](https://www.ncbi.nlm.nih.gov/), and formatted into a single fasta [file](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/all_COIseqs.fasta).

Once got a fasta file including all COI sequences, it was aligned using MAFFT:

```
mafft --adjustdirection COI_sequences.fasta > aligned_COI.fasta
```

The aligned file was then submitted to trimal:

```
trimal -in aligned_COI.fasta -resoverlap 0.5 -seqoverlap 50 -gappyout > trimmed_COI.fasta
```

Before proceeding, the trimmed file was furtherly processed using [AliView - Alignment Viewer and Editor](https://ormbunkar.se/aliview/) to delete poorly aligned regions.

A second FASTA [file](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/trimmed_onesp_COIseqs_def.fasta), containing one COI sequence per *Timema* species as well as sequences from all euphasmatodean species and outgroups, was manually created.

An ultrametric tree for each dataset was inferred using BEAST2 tools package.
Two `.xml` files were set using the software application BEAUti (Bayesian Evolutionary Analysis Utility), with the features specified in this [`.tsv`](https://github.com/MattiaRag/timemaproject/blob/main/scripts/BEAUTI_feat.tsv), in both datasets. Topological constraints were applied to each node of the relevant tree in the reduced dataset. In the extensive dataset, all nodes were constrained except for those within the Timema clade, to allow verification of the potential polyphyly within this clade. Topological data were retrieved from [Parker at al. 2019](https://www.researchgate.net/publication/336424541_Sex-biased_gene_expression_is_repeatedly_masculinized_in_asexual_females), calibration data from [Tihelka et al. 2020](https://royalsocietypublishing.org/doi/10.1098/rsos.201689) and [Riesch et al. 2017](https://www.nature.com/articles/s41559-017-0082).

The exported `.xml` files were then submitted to beast, running 2 analyses independently, for each dataset:

```
./beast beastTIMEMA.xml
```

For each dataset, both runs were checked for convergence and ESS values using Tracer. An appropriate [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/extract_1000trees.py) was then employed for both the reduced and extensive datasets. These scripts were used to randomly select 500 trees from each MCMC run after applying an initial burn-in of 10%. The selected trees were combined to generate a new .trees file containing a total of 1,000 randomly extracted trees. 

```
python extract_1000trees.py input_file1.trees input_file2.trees 1k_random_sampling.trees
```

The computed files can be retrieved [here](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/1k_random_sampling_reduced.trees) for the reduced and [here](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/1k_random_sampling_extended.trees) for the extensive datasets.

Both MCMC (Markov Chain Monte Carlo) runs were combined using LogCombiner:

```
./../beast/bin/logcombiner -log part_2a/beast/treerun1/beastTIMEMA-trimmedDEFINITIVEspnames.trees -log part_2a/beast/treerun2/beastTIMEMA-trimmedDEFINITIVEspnames.trees -o combined.trees -burnin 10
```

The sampled trees were then summarized using TreeAnnotator. Given the large size of the `.trees` files, a dedicated [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/sample_trees.py) was employed to sub-sample 4,000 trees from each distribution at regular intervals to ensure even representation across the dataset.

```
python sample_trees.py combined.trees output_4000.trees
./../beast/bin/treeannotator -burnin 10 -height CA part_2a/beast/output_4000.trees part_2a/beast/MCC_sampling.tree
```

The post-Treeannotator trees can be retrieved [here](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/MCC_sampling_reduced.tree) for the reduced dataset and [here](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/MCC_sampling_extended.tree) for the extensive dataset.

## Infer the ancestral state reconstruction

A [R script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/Rscripts/part_3.R) was used to infer the ASR (Ancestral State Reconstruction) on both reduced and extensive datasets. The script accepts as input the following files:
* 


Both analyses revealed uncertainty regarding the reproductive strategy of the *Timema* MRCA.

Th out
---


[main](https://github.com/MattiaRag/timemaproject/tree/main) /
[exp_des](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/exp_design.md) /
[prel](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/preliminary.md) /
[1](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_1.md) /
[2](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_2.md) /
3 /
[4](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_4.md)  

