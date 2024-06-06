# Hemiplasy hypothesis - inference-based approach


*environiments:* yaml.main 


*aim:* prepare inputs for HeIST and run it

As input for HeIST, it is necessary to prepare a txt file including two species trees, one of which indicates the gene concordance factors (gCFs), a measure for quantifying genealogical concordance in phylogenomic datasets. For every branch of a reference tree, gCF is defined as the percentage of “decisive” gene trees containing that branch. 


## Infer species tree for both nucleotidic and aminoacidic sequences

**NB1:** The species trees are inferred using this [script for aminoacidic sequences](https://github.com/MattiaRag/timemaproject/blob/main/scripts/species_tree_aa.sh) and this [script for nucleotidic sequences](https://github.com/MattiaRag/timemaproject/blob/main/scripts/species_tree_nu.sh). The current chapter provides a detailed description of commands constituting the concerned pipeline, taking aminoacidic sequences as example model. 

**NB2:** In order to test the performances of subsequent analyses on different subsets of data, both sets of orthogroups are split into two subsets: one including all orthogroups (with a minimum of 5 species each) and one including only orthogroups comprising all 10 species.



At first, all trimmed files are copied and paste into the new directory `sptree_aa/min_5sp`.

```
cp preliminary/orthogroupsdisco_aa/Trimmed_aa/*.fa species_trees/sptree_aa/min_5sp

```

One further directory called `sptree_aa/min_10sp` is generated and orthogroups' fastas including all 10 species are copied and paste in there. These steps are performed through a `for` cycle:

```
for i in species_trees/sptree_aa/min_5sp/*.fa; do
    # Count the number of headers in the file
    num_headers=$(grep -c '^>' "$i")

    # If the number of headers is greater than or equal to 10
    if [ "$num_headers" -ge 10 ]; then
        # Copy the file to min_10sp directory
        cp "$i" species_trees/sptree_aa/min_10sp/
    else
        echo "The file $i contains less than 10 headers. Skipping to the next step."
    fi
done
```

The following steps must be performed on both `min_5sp` and `min_10sp` directories.

Before concatenation, the fastas' headers are renamed keeping just the species names (e.g. TPA, TBI, etc.), while empty files are also removed: 

```
awk '/^>/{split(species_trees/sptree_aa/min_5sp, arr, "_"); print arr[1]; next} {print}' "orth.fa" > species_trees/sptree_aa/min_5sp/Renamed/orth.rename
find species_trees/sptree_aa/min_5sp/Renamed -type f -size 0 -delete
```

Concatenation is then operated using AMAS.py on the `Renamed` directory:

```
python scripts/AMAS.py concat -y nexus -i species_trees/sptree_aa/min_5sp/Renamed/*.rename -f fasta -d aa -t species_trees/sptree_aa/min_5sp/Iqtreeinput/concat_file
```

The flag `-y` specifies the format of the output file. 
The flag `-d` is used to specify the type of data being processed. This flag takes value `aa` for aminoacidic and `dna` for nucleotidic sequences.
The flag `-f` is used to specify the format of the input files.

Concatenation is directly followed by Iqtree2:

```
iqtree2 -m TESTNEW -bb 1000 -s species_trees/sptree_aa/min_5sp/Iqtreeinput/concat_file --prefix species_trees/sptree_aa/min_5sp/Iqtreeoutput/concat_file.faa -nt AUTO
```


