# Requirements and dataset explanation


*environiment:* ...


*aim:* set up conda environiments / obtain cds and proteoms / understand experimental design


---


Clone the github to a local host and then:


- install the sotwares
- download the databases
- download the experiment data

**NB1**: all command lines reported here have to be launched from the project main folder.

---


### Install the software


Due to conflicts specific environiments are necessary for expression analyses. They can be installed by: 


```
conda env create -n agat
``` 

List of tools needed to be installed:

- AGAT

```
conda activate agat
conda install -c bioconda agat 
``` 
For further details visit this [page](https://github.com/NBISweden/AGAT?tab=readme-ov-file#using-bioconda)

...

---


### Download the sequences and relative data 


Files necessary for extracting cds (coding sequences) and proteoms for all 10 species can be downloaded using wget on the relative links, then redirected to the proper folders.

This can be performed by running this script, which will create a docs directory and use a tsv file for downloading all gff and fasta documents.

### Obtain cds and proteoms

## Before extracting cds and proteoms, make sure to keep just the longest isoforms, with the following command, to re-iterate on all gff files:

```
agat_sp_keep_longest_isoform.pl -gff gff_file -o longest_isoform_gff

```

## Extract nucleotide sequences with AGAT, re-iterating on longest isoform gff and fasta of all 10 species:

```
agat_sp_extract_sequences.pl --gff longest_isoform_gff --fasta fasta_file --cfs --type CDS --output sp_outputcds.fa

```
The "--cfs" flag allows to remove the final stop codons.

## Extract proteoms with AGAT, re-iterating on longest isoform gff and fasta of all 10 species:

```
agat_sp_extract_sequences.pl --gff longest_isoform_gff --fasta fasta_file -p --cfs --type exon --output sp_outputcds.fa

```
The "-p" flag allows to translate nucleotide sequences in aminoacid sequences.       


**NB2**: all commands needed for obtaining correctly formatted cds and proteoms have been implemented within this script. 


