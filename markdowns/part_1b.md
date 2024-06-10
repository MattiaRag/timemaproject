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
