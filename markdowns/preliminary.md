# Requirements and dataset explanation


*environiment:* agat


*aim:* set up conda environiments / obtain cds and proteoms / understand experimental design


---


Clone the github to a local host and then:


- install the sotwares
- download the databases
- download the experiment data

**NB1**: all command lines reported here have to be launched from the project main folder.

---


## Install the softwares


Due to conflicts specific environiments are necessary for expression analyses. They can be installed by: 


```
conda env create -n agat
``` 

List of tools needed to be installed:

- [AGAT](https://github.com/NBISweden/AGAT/tree/master) (Another Gtf/Gff Analysis Toolkit)

```
conda activate agat
conda install -c bioconda agat 
``` 
For further details visit this [page](https://github.com/NBISweden/AGAT?tab=readme-ov-file#using-bioconda)



## Download the sequences and relative data 


Files necessary for extracting cds (coding sequences) and proteoms for all 10 species can be downloaded using wget on the relative links, then redirected to the proper folders.

This can be performed by running this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/download_files.sh), which will create a docs directory and use a [tsv file](https://github.com/MattiaRag/timemaproject/blob/main/scripts/downloading_links.tsv) for downloading all gff and fasta documents.

**NB:** datasets were downloaded in May 2024.

## Obtain cds and proteoms

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



## Experimental design


This project ... with two major aims:


1. charachterize in crema genes associated with feeding on vicia extra-floral nectar (EFN) in different tissues and timespans.
2. understand wether we could identify in vicia any gene expression change associated to the interaction.


To do so we generated two RNA-seq experiments:


1. two different tissue (haead+thorax and abdomen) and four different conditions were considered for crema:


**A**  -  never got in contact with vicia

**B**  -  got in contact with vicia only since 24h before experiment

**C**  -  got in contact with vicia only until 24h before experiment 

**D**  -  got in contact with vicia continuously


2. nectarium of vicia which:

**N**  -  never got in contact with crema

**Y**  -  2' after beeing visited by crema
