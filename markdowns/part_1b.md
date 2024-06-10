# Hemiplasy hypothesis - detection of hemiplasic candidate genes


*environiments:* yaml.main 


*aim:* infer Fitch parsimony / assigne GO terms through OMA / gene enrichment 


**NB:** In order to test the performances of subsequent analyses on different subsets of data, both sets of orthogroups are split into two subsets: one including all orthogroups (with a minimum of 5 species each) and one including only orthogroups comprising all 10 species. 

Each of the following commands must thus be applied to four subsets, in total: 
* all aminoacids-composed orthogroups (min 5 species);
* aminoacids-composed orthogroups with minimimum 10 species;
* all nucleotides-composed orthogroups (min 5 species);
* nucleotides-composed orthogroups with minimimum 10 species.

## Infer Fitch parsimony

The Fitch parsimony test was retrieved ...

## GO terms assignment

In order to perform a gene enrichment of hemiplasic candidate genes, it is necessary to annotate all aminoacidic sequences retrieved after orthology inference and decomposition in single-copy orthogroups.

This was perform by using the online tools set provided by OMA (Orthologous MAtrix), and specifically the funtional prediction, available at this [link](https://omabrowser.org/oma/functions/). 
This tool accepts an input fasta file, containing all aminoacidic sequences from all species and orthogroups. Not to lose any of the identifier codes, the header of each sequence was renamed with the identification code of the orthogroups as first field and the identification code of the sequence as second field, separated by an underscore (e.g. `>10000_TCE_01291-RA`). This was performed using a proper [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/OMAinput.sh). 

The complete fasta input file was submitted to OMA browser and an output was subsequently retrieved in `.txt` format. 

## Gene enrichment in R

As input for gene enrichment in R, a properly formatted `.txt` document is necessary. It is composed of a first column indicating the orthogroup's name, and a second tab-delimited column composed of all comma-delimited GO terms assigned to the relative orthogroup. This can be performed through this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/OMAoutput_formatting.sh) on the OMA output file.

 
 
