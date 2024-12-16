#!/bin/bash


# Input and output directories

input_dir="preliminary/orthogroupsdisco_aa/Iqtreeinput_aa"

model_dir="preliminary/orthogroupsdisco_aa/modelselectioniqtree_aa"

output_dir="preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa_constrained"


# Create the output directory if it doesn't exist

mkdir -p "$output_dir"


# Loop over all .input.fa files in the input directory

for msa_file in "$input_dir"/*.input.fa; do

    # Extract the base name (e.g., 9994)

    base_name=$(basename "$msa_file" .input.fa)

    

    # Define the topology file and log file for the best-fit model

    cladogram_file="$input_dir/${base_name}.input_cladogram.nwk"

    model_log_file="$model_dir/${base_name}.log"

    

    # Check if the required files exist

    if [[ ! -f "$cladogram_file" ]]; then

        echo "Error: Missing topology file for $base_name. Skipping."

        continue

    fi

    

    if [[ ! -f "$model_log_file" ]]; then

        echo "Error: Missing model log file for $base_name. Skipping."

        continue

    fi

    

    # Extract the best-fit model from the log file

    best_model=$(grep "Best-fit model" "$model_log_file" | sed -E 's/.+: (.[^ ]+) .+/\1/')

    

    if [[ -z "$best_model" ]]; then

        echo "Error: No model found in $model_log_file. Skipping."

        continue

    fi

    

    # Define the output prefix

    output_prefix="$output_dir/$base_name"

    

    # Run the RAxML-NG command

    raxml-ng --msa "$msa_file" --tree "$cladogram_file" --model "$best_model" --prefix "$output_prefix" --evaluate --seeds 3

    

    # Print progress message

    echo "Processed $msa_file with model $best_model and prefix $output_prefix"

done


echo "All files processed. Outputs are saved in $output_dir."

