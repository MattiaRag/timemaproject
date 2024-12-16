#!/bin/bash


# Define input and output directories

input_dir="preliminary/orthogroupsdisco_aa/Iqtreeinput_aa"

output_dir="preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa_constrained"


# Create the output directory if it doesn't exist

mkdir -p "$output_dir"


# Specify the target file

target_file="$input_dir/8627.input.fa"

topology_file="$input_dir/8627.input_cladogram.nwk"


# Check if the target file and topology file exist

if [ ! -f "$target_file" ]; then

    echo "ERROR: Target file not found: $target_file. Exiting."

    exit 1

fi


if [ ! -f "$topology_file" ]; then

    echo "ERROR: Topology file not found: $topology_file. Exiting."

    exit 1

fi


# Define the output prefix for IQ-TREE

output_prefix="$output_dir/8627"


# Run IQ-TREE with the constrained topology

iqtree -s "$target_file" -t "$topology_file" -pre "$output_prefix" -nt 4 -keep-ident


# Print a message indicating completion

echo "Processed $target_file with topology $topology_file"

echo "Output saved in $output_dir"

