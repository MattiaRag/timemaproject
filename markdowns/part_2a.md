# Ancestral state hypothesis - impact of evolutionary model assumption


*environiments:* yaml.main 


*aim:* infer an ultrametric tree with BEAST2 / infer the Ancestral State Recostruction (ASR) 


## Infer an ultrametric tree with BEAST2

Bayesian Inference was performed on two datasets: a reduced dataset where all 15 known *Timema* species were represented by a single sequence and an extensive dataset encompassing over one hundred specimens. Both datasets consisted of mitochondrial COI sequences, as they are the only comparable sequence data available for all *Timema* species. Both datasets also included 14 species of Euphasmatodea (the sister clade of Timematodea) and two outgroup species (Embiopterans).
The sequences can be downloaded from [NCBI](https://www.ncbi.nlm.nih.gov/), and formatted into a single fasta file through this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/downloading_COIseq.sh).

Once got a fasta file including all COI sequences, it was aligned using MAFFT:

```
mafft --adjustdirection COI_sequences.fasta > aligned_COI.fasta
```

The aligned file was then submitted to trimal:

```
trimal -in aligned_COI.fasta -resoverlap 0.5 -seqoverlap 50 -gappyout > trimmed_COI.fasta
```

Before proceeding, the trimmed file was furtherly processed using [AliView - Alignment Viewer and Editor](https://ormbunkar.se/aliview/) to delete poorly aligned regions.

The ultrametric tree was inferred using BEAST2 tools package.
An `.xml` file was set using the software application BEAUti (Bayesian Evolutionary Analysis Utility), with the features specified in this [`.tsv`](https://github.com/MattiaRag/timemaproject/blob/main/scripts/BEAUTI_feat.tsv). Topological constrains were included for each node of the concerned tree. Both calibration and topological data were retrieved from [Parker at al. 2019](https://www.researchgate.net/publication/336424541_Sex-biased_gene_expression_is_repeatedly_masculinized_in_asexual_females) and [Tihelka et al. 2020](https://royalsocietypublishing.org/doi/10.1098/rsos.201689).

The exported `.xml` file was then submitted to beast, running 2 analyses independently:

```
./beast beastTIMEMA.xml
```

Both runs were checked for convergence and ESS values using Tracer. A proper [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/extract_1000trees.py) was then adopted to randomly select 500 trees from each run (performing an initial burnin of 10%) and create a further `.trees` file including a total of 1000 randomly extracted trees. The computed file can be retrieved [here](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/extracted_1000.trees).

Both MCMC (Markov Chain Monte Carlo) runs were combined using LogCombiner, while subsequently summarizing the trees sampled using TreeAnnotator, obtaining a single [tree](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/treeannotator_output.tree):

```
./../beast/bin/logcombiner -log part_2a/beast/treerun1/beastTIMEMA-trimmedDEFINITIVEspnames.trees -log part_2a/beast/treerun2/beastTIMEMA-trimmedDEFINITIVEspnames.trees -o combined.trees -burnin 1000
./../beast/bin/treeannotator -burnin 10 -height CA part_2a/beast/combined.trees part_2a/beast/treeannotator_output.tree
```

## Infer the ancestral state reconstruction

A [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/ASR.R) in R can be used.

---


[main](https://github.com/MattiaRag/timemaproject/tree/main) /
[exp_des](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/exp_design.md) /
[prel](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/preliminary.md) /
[1a](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_1a.md) /
[1b](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_1b.md) /
2a /
[2b](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_2b.md)  

