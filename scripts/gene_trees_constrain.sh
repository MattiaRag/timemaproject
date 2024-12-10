#!/bin/bash


# Define input and output directories

input_dir="preliminary/orthogroupsdisco_aa/Iqtreeinput_aa"

output_dir="preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa_constrained"


# Create the output directory if it doesn't exist

mkdir -p "$output_dir"


# Iterate over all *.input.fa files in the input directory

for fasta_file in "$input_dir"/*.input.fa; do

    # Extract the base name without extension

    base_name=$(basename "$fasta_file" .input.fa)


    # Define the corresponding topology file with the correct naming convention

    topology_file="$input_dir/${base_name}.input_cladogram.nwk"


    # Check if the topology file exists

    if [ ! -f "$topology_file" ]; then

        echo "WARNING: Topology file not found: $topology_file. Skipping $fasta_file."

        continue

    fi


    # Define the output prefix for IQ-TREE

    output_prefix="$output_dir/${base_name}"


    # Run IQ-TREE with the constrained topology

    iqtree -s "$fasta_file" -t "$topology_file" -pre "$output_prefix" -nt 4


    # Print a message to track progress

    echo "Processed $fasta_file with topology $topology_file"

done


echo "All files have been processed. Outputs are saved in $output_dir."

