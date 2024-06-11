# Hemiplasy hypothesis - detection of hemiplasic candidate genes


*environiments:* yaml.main 


*aim:* infer Fitch parsimony / assigne GO terms through OMA / gene enrichment 


## Infer Fitch parsimony

The Fitch parsimony test was applied on a properly formatted input file, composed of a first column indicating the orthogroup's name, followed with a second tab-delimited column including the relative sequences-derived gene trees in Newick format. As the same input was used for the [part_2a](https://github.com/MattiaRag/timemaproject/blob/main/markdowns/part_2a.md), these files were obtained using a single [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/fitch_asr_input.sh). They can be retrieved [here](https://github.com/MattiaRag/timemaproject/tree/main/intermediate_files/fitch_asr_inputs).

An other input file, in `.tsv` format, is needed, and composed of a first column including codes from all 10 species, followed by a second column including a codified information on the species (0 = bisexual species, 1 = parthenogenetic species).

The Fitch parsimony test [Rscript](https://github.com/MattiaRag/timemaproject/blob/main/scripts/fitch.R) was run using the following command lines:


```
Rscript scripts/fitch.R part_2a/asr/fitch_asr_input_aa.txt scripts/trait.tsv >> part_1b/fitch_test/fitch_results_aa.txt
Rscript scripts/fitch.R part_2a/asr/fitch_asr_input_nu.txt scripts/trait.tsv >> part_1b/fitch_test/fitch_results_nu.txt
```

The fitch parsimony results can be retrieved [here](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/fitch_results.txt).


## GO terms assignment

In order to perform a gene enrichment of hemiplasic candidate genes, it is necessary to annotate all aminoacidic sequences retrieved after orthology inference and decomposition in single-copy orthogroups.

This was perform by using the online tools set provided by OMA (Orthologous MAtrix), and specifically the funtional prediction, available at this [link](https://omabrowser.org/oma/functions/). 
This tool accepts an input fasta file, containing all aminoacidic sequences from all species and orthogroups. Not to lose any of the identifier codes, the header of each sequence was renamed with the identification code of the orthogroups as first field and the identification code of the sequence as second field, separated by an underscore (e.g. `>10000_TCE_01291-RA`). This was performed using a proper [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/OMAinput.sh). 

The complete fasta input file was submitted to OMA browser and an output was subsequently retrieved in `.txt` format. 

## Gene enrichment in R

As input for gene enrichment in R, a properly formatted `.txt` document is necessary. It is composed of a first column indicating the orthogroup's name, and a second tab-delimited column composed of all comma-delimited GO terms assigned to the relative orthogroup. This can be performed through this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/OMAoutput_formatting.sh) on the OMA output file. The computed file can be retrieved [here](https://github.com/MattiaRag/timemaproject/blob/main/intermediate_files/OMA_formatted.txt).

 
 
