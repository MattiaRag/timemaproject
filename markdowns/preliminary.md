# Requirements and dataset explanation


*environiments:* agat / orthofinder


*aim:* set up mamba environiments / obtain cds and proteoms / infer single-copy orthogroups


---


Clone the github to a local host and then:


- install the softwares
- download the databases
- download the experiment data

**NB1**: all command lines reported here have to be launched from the project main folder.

---


## Install the softwares


Due to conflicts specific environiments are necessary for expression analyses. They can be installed by: 


```
mamba create --name myenvname orthofinder
mamba create --name myenvname agat
``` 

List of tools needed to be installed:

- [AGAT](https://github.com/NBISweden/AGAT/tree/master) (Another Gtf/Gff Analysis Toolkit)
- [Orthofinder](https://github.com/davidemms/OrthoFinder)

```
mamba activate agat
mamba install agat 
``` 
For further details visit this [page](https://bioconda.github.io/recipes/agat/README.html)

```
mamba activate orthofinder
https://bioconda.github.io/recipes/orthofinder/README.html 
``` 
For further details visit this [page](https://bioconda.github.io/recipes/orthofinder/README.html)


## Download the sequences and relative data 


Files necessary for extracting cds (coding sequences) and proteoms for all 10 species can be downloaded using wget on the relative links, then redirected to the proper folders.

This can be performed by running this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/download_files.sh), which will create a docs directory and use a [tsv file](https://github.com/MattiaRag/timemaproject/blob/main/scripts/downloading_links.tsv) for downloading all gff and fasta documents.

**NB:** datasets were downloaded in May 2024.

## Obtain cds and proteoms

### Activate mamba environment agat

```
mamba activate agat
``` 

### Before extracting cds and proteoms, make sure to keep just the longest isoforms, with the following command, to re-iterate on all gff files:

```
agat_sp_keep_longest_isoform.pl -gff gff_file -o longest_isoform_gff

```

### Extract nucleotide sequences with AGAT, re-iterating on longest isoform gff and fasta of all 10 species:

```
agat_sp_extract_sequences.pl --gff longest_isoform_gff --fasta fasta_file --cfs --type CDS --output sp_outputcds.fa

```
The "--cfs" flag allows to remove the final stop codons.

### Extract proteoms with AGAT, re-iterating on longest isoform gff and fasta of all 10 species:

```
agat_sp_extract_sequences.pl --gff longest_isoform_gff --fasta fasta_file -p --cfs --type exon --output sp_outputcds.fa

```
The "-p" flag allows to translate nucleotide sequences in aminoacid sequences.       


**NB2**: all commands needed for obtaining correctly formatted cds and proteoms have been implemented within this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/agatscript.sh).



## Inferring single-copy orthogroups

Most of the subsequent analyses request the use of single-copy orthogroups, thus discarding paralogs. Orthofinder was adopted for the orthology inference, while DISCO ( 


### Activate mamba environment orthofinder

```
mamba activate orthofinder
``` 


