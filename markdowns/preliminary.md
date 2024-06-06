# Requirements and dataset explanation


*environiments:* base / agat / orthofinder


*aim:* set up mamba environiments / obtain cds and proteoms / infer single-copy orthogroups and relative gene trees


---


Clone the github to a local host and then:


- install the softwares
- download the databases
- download the experiment data

**NB**: all command lines reported here have to be launched from the project main folder.

---


## Install the softwares


Due to conflicts specific environiments are necessary for expression analyses. They can be installed by: 


```
mamba create --name myenvname orthofinder
mamba create --name myenvname agat
``` 

### List of tools needed to be installed:


- [AGAT - Another GFF Analysis Toolkit - Version: v0.8.0](https://github.com/NBISweden/AGAT/tree/master)
- [OrthoFinder - Version 2.5.5](https://github.com/davidemms/OrthoFinder)
- [DISCO - Decomposition Into Single-COpy gene trees - Version: v1.3.1](https://github.com/JSdoubleL/DISCO?tab=readme-ov-file)
- [MAFFT - Multiple Alignment using Fast Fourier Transform - Version: v7.520](https://github.com/GSLBiotech/mafft)
- [trimAL - Version: v1.4.rev22](https://vicfero.github.io/trimal/index.html)
- [AMAS - Alignment manipulation and summary statistics - Version: v0.9](https://github.com/marekborowiec/AMAS)
- [IQ-TREE multicore - Version: 2.2.2.6 COVID-edition](https://github.com/iqtree/iqtree2/releases/tag/v2.2.2.6) 
 
### Installation of tools needing dedicated environmnents:


```
mamba activate agat
mamba install agat 
mamba deactivate
``` 
For further details on AGAT installation visit this [page](https://bioconda.github.io/recipes/agat/README.html)


```
mamba activate orthofinder
mamba install orthofinder
mamba deactivate 
``` 
For further details on Orthofinder installation visit this [page](https://bioconda.github.io/recipes/orthofinder/README.html)


### Installation of tools executables on base environment: 


```
git clone https://github.com/JSdoubleL/DISCO.git
```

DISCO's exectuable can be downloaded using git clone, but to make DISCO work, it may be necessary to manually install the dependency called "treeswift":

```
pip install treeswift
```
In this case, `disco.py` was placed in preliminary/scripts and called from there while running the command.


```
mamba install mafft
```
For further details on MAFFT installation visit this [page](https://mafft.cbrc.jp/alignment/software/)


```
mamba install trimal
```
For further details on MAFFT installation visit this [page](https://bioconda.github.io/recipes/trimal/README.html)


```
mamba install iqtree       
```
For further details on iqtree installation visit this [page](https://bioconda.github.io/recipes/iqtree/README.html)


```
git clone https://github.com/marekborowiec/AMAS.git
```

AMAS' exectuable can be downloaded using git clone. 
In this case, `AMAS.py` was placed in preliminary/scripts and called from there while running the command.


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
The flag `--cfs` allows to remove the final stop codons.

### Extract proteoms with AGAT, re-iterating on longest isoform gff and fasta of all 10 species:


```
agat_sp_extract_sequences.pl --gff longest_isoform_gff --fasta fasta_file -p --cfs --type exon --output sp_outputcds.fa
```

The flag `-p` allows to translate nucleotide sequences in aminoacid sequences.       


**NB**: all commands needed for obtaining correctly formatted cds and proteoms have been implemented within this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/agatscript.sh).



## Inferring single-copy orthogroups


Most of the subsequent analyses request the use of single-copy orthogroups, thus discarding paralogs. Orthofinder was adopted for the orthology inference, while DISCO was used to decompose Orthofinder's gene trees into single-copy gene trees only. Orthogroups' fastas were subsequently re-built using DISCO's output. 


### Rename headers and set the input directory


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
The flag `-y` allows to split paralogous clades below root of a HOG into separate HIGs.

In the current pipeline, the command has been run through this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/orthofinder.sh).

### Prepare input and run DISCO


As input for DISCO, it is recommended to prepare a newick-formatted file composed of all gene trees produced by Orthofinder, and filed in the output directory `Gene_Trees`.

Moreover, Orthofinder will rename the tips within each gene tree adding, immediately before the unique identifier code, the name of the original fasta file from which the relative record was extracted (which usually include the species name). It is thus recommended to modify the gene trees tips' names keeping just the unique identifier code (in this case, to make the subsequent orthogroups' reconstruction quicker, even a repetition of the species name was kept in the tips' names).

The tips' renaming and input file formatting can be performed through this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/discorename.sh).

Disco run can be performed through the following command line:

```
python3 scripts/disco.py -i preliminary/disco/input_disco.trees -o preliminary/disco/discooutputDEF5.txt -d "_" -n 1 --keep-labels -m 5
```

The flag `--keep-labels` allows to keep original leaf labels instead of using species name, while the flag `-m` specifies the minimum number of taxa required for tree to be outputted.
 
### Reconstruct orthogroups post-DISCO


Before inferring new gene trees, it is necessary to generate fasta files of both aminoacidic and nucleotidic sequences, for each new single-copy orthogroup elaborated by DISCO.

This operation was performed for [aminoacids](https://github.com/MattiaRag/timemaproject/blob/main/scripts/extractdisco_aa.sh) and [nucleotides](https://github.com/MattiaRag/timemaproject/blob/main/scripts/extractdisco_nu.sh) with proper scripts, using DISCO output `discooutputDEF5.trees` as input.

### Infer gene trees for both aminoacids and nucleotides


With slight differences later specified, the steps leading to gene tree inference are the same for aminoacids and nucleotides-composed orthogroups. Alignement and trimming are performed on aminoacids only, subsequently back-translating the trimmed files, thanks to a proper trimAL flag.

The aminoacidic sequences alignment is performed using MAFFT on each fasta file:

```
mafft --auto orthogroupsdisco_aa/orth.fa > Maffted/orth.mafft.fa
```


All alignments are then trimmed, using specific flags:

```
trimal -in Maffted/orth.mafft.fa -resoverlap 0.5 -seqoverlap 50 -gappyout > Trimmed_aa/orth.trimmed.fa
```

The flag `-resoverlap` specifies the minimum overlap of a positions with other positions in the column to be considered a "good position".
The flag `-seqoverlap` specifies the minimum percentage of "good positions" that a sequence must have in order to be conserved.
The flag `-gappyout` automatically remove columns from the alignment that contain gaps according to a predefined threshold.

The first run of trimAL produces trimmed aminoacidic sequences.

```
trimal -in Maffted/orth.mafft.fa -resoverlap 0.5 -seqoverlap 50 -gappyout -ignorestopcodon -backtrans orthogroupsdisco_nu/orth.fa > Trimmed_nu/orth.trimmed.fa
```

The second run of trimAL repeats trimming on aminoacidic sequences, while automatically back-translating the trimmed sequences to nucleotides, thanks to the flag `-backtrans` followed by the previously provided relative orthogroup's fasta file in nucleotides sequences.

The flag `-ignorestopcodon` makes the tool ignore stop codons in the input coding sequences.


Trimmed fasta files are then processed independtly for aminoacidic and nucleotidic sequences.

After renaming the headers, keeping just the species name, fasta aminoacids files are checked for the number of headers they include. If this is smaller than 5, they are moved to the separate directory `lessthan5headers`, otherwise, Iqtree2 is performed:

```
iqtree2 -s Iqtreeinput_aa/orth.input.fa --prefix Iqtreeoutput_aa/loci_orth -T 8
``` 

The same steps are performed on fasta nucleotides files, followed by Iqtree2:

```
iqtree2 -s Iqtreeinput_nu/orth.input.fa --prefix Iqtreeoutput_nu/loci_orth -T 8
```
 
**NB**: all commands needed for obtaining gene trees for both aminoacidic and nucleotidic sequences have been implemented within this [script](https://github.com/MattiaRag/timemaproject/blob/main/scripts/gene_trees.sh).
