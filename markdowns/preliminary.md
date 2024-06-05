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

- [Another GFF Analysis Toolkit (AGAT) - Version: v0.8.0](https://github.com/NBISweden/AGAT/tree/master) (Another Gtf/Gff Analysis Toolkit)
- [OrthoFinder version 2.5.5](https://github.com/davidemms/OrthoFinder)

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


### Rename headers and set the input folder

Before running Orthofinder and subsequent analyses, rename the fasta file headers keeping just the species name and the unique code of the sequence (e.g. TBI_11170_RA).
This can be done through this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/rename_multitoone.sh) on both aminoacidic (proteomes) and nucleotidic sequences (cds), extracted with AGAT.

As the current settings don't allow the redirection of Orthofinder's outputs, they will be produced within the same input folder. For this reason, in order to keep directories' order, copy the renamed and one line aminoacidic sequences into a new directory, possibly called "Orthofinder".

### Activate mamba environment orthofinder

```
mamba activate orthofinder
```

### Run orthofinder

Orthofinder can be run on the renamed and one line aminoacidic sequences, through the following command line:

```
orthofinder -f input_dirrectory -y
```
The "y" flag allows to split paralogous clades below root of a HOG into separate HIGs.

In the current pipeline, the command has been run through this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/orthofinder.sh).
