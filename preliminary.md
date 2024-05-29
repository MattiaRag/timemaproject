# Requirements and dataset explanation


*environiment:* ...


*aim:* set up conda environiments / obtain cds and proteoms / understand experimental design


---


Clone the github to a local host and then:


- install the sotware
- download the databases
- download the experiment data


---


### install the software


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
For further details visit https://github.com/NBISweden/AGAT?tab=readme-ov-file#using-bioconda

...

---


### download the sequences and relative data 


Files necessary for extracting cds (coding sequences) and proteoms for all 10 species can be downloaded using wget on the following links and redirected to the relative folders:

Gff files:

- https://zenodo.org/records/5636226/files/Tbi_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tce_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tcm_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tdi_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tge_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tms_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tpa_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tps_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tsi_b3v08.max_arth_b2g_droso_b2g.gff?download=1
- https://zenodo.org/records/5636226/files/Tte_b3v08.max_arth_b2g_droso_b2g.gff?download=1

Fasta files:

- https://zenodo.org/records/5636226/files/Tbi_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tce_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tcm_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tdi_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tge_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tms_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tpa_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tps_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tsi_b3v08.fasta?download=1
- https://zenodo.org/records/5636226/files/Tte_b3v08.fasta?download=1

Example command:

```
wget https://zenodo.org/records/5636226/files/Tte_b3v08.fasta?download=1
```

### before extracting cds and proteoms, make sure to keep just the longest isoforms, with the following command, to re-iterate on all gff files:

```
agat_sp_keep_longest_isoform.pl -gff gff_file -o longest_isoform_gff

```

### extract nucleotide sequences with AGAT, re-iterating on longest isoform gff and fasta of all 10 species:

```
agat_sp_extract_sequences.pl --gff longest_isoform_gff --fasta fasta_file --cfs --type CDS --output sp_outputcds.fa

```
The "--cfs" flag allows to remove the final stop codons.

### extract proteoms with AGAT, re-iterating on longest isoform gff and fasta of all 10 species:

```
agat_sp_extract_sequences.pl --gff longest_isoform_gff --fasta fasta_file -p --cfs --type exon --output sp_outputcds.fa

```
The "-p" flag allows to translate nucleotide sequences in aminoacid sequences.       


