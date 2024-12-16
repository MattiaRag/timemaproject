#!/bin/bash


# Input and output directories

input_dir="preliminary/orthogroupsdisco_aa/Iqtreeinput_aa"

model_dir="preliminary/orthogroupsdisco_aa/modelselectioniqtree_aa"

output_dir="preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa_constrained"


# Create the output directory if it doesn't exist

mkdir -p "$output_dir"


# File specific to code 8627

msa_file="$input_dir/8627.input.fa"

cladogram_file="$input_dir/8627.input_cladogram.nwk"

model_log_file="$model_dir/8627.log"


# Check if the required files exist

if [[ ! -f "$msa_file" ]]; then

    echo "Error: Missing MSA file for 8627. Exiting."

    exit 1

fi


if [[ ! -f "$cladogram_file" ]]; then

    echo "Error: Missing topology file for 8627. Exiting."

    exit 1

fi


if [[ ! -f "$model_log_file" ]]; then

    echo "Error: Missing model log file for 8627. Exiting."

    exit 1

fi


# Extract the best-fit model from the log file

best_model=$(grep "Best-fit model" "$model_log_file" | sed -E 's/.+: (.[^ ]+) .+/\1/')


if [[ -z "$best_model" ]]; then

    echo "Error: No model found in $model_log_file. Exiting."

    exit 1

fi


# Define the output prefix

output_prefix="$output_dir/8627"


# Run the RAxML-NG command

raxml-ng --msa "$msa_file" --tree "$cladogram_file" --model "$best_model" --prefix "$output_prefix" --evaluate --seed 3


# Print progress message

echo "Processed $msa_file with model $best_model and prefix $output_prefix"


echo "Processing completed. Output is saved in $output_dir."

