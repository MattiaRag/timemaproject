#!/bin/bash


# Input, output, and error directories

input_dir="preliminary/orthogroupsdisco_aa/Iqtreeinput_aa"

model_dir="preliminary/orthogroupsdisco_aa/modelselectioniqtree_aa"

output_dir="preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa_constrained"

error_dir="preliminary/orthogroupsdisco_aa/raxml_errors"


# Create necessary directories if they don't exist

mkdir -p "$output_dir"

mkdir -p "$error_dir"


# Function to map incompatible models and their variants from IQ-TREE to RAxML equivalents

map_model() {

    case "$1" in

        "JTTDCMut"|"JTTDCMut+F"|"JTTDCMut+G4"|"JTTDCMut+I"|"JTTDCMut+I+G4"|"JTTDCMut+R2"|"JTTDCMut+R3"|"JTTDCMut+R4"|"JTTDCMut+F+G4"|"JTTDCMut+F+I"|"JTTDCMut+F+I+G4"|"JTTDCMut+F+R2"|"JTTDCMut+F+R3") echo "JTT" ;;

        "mtInv"|"mtInv+F"|"mtInv+F+G4"|"mtInv+F+I"|"mtInv+F+I+G4") echo "mtREV" ;;

        "mtMet"|"mtMet+F"|"mtMet+F+G4"|"mtMet+F+I"|"mtMet+F+I+G4"|"mtMet+F+R2"|"mtMet+G4"|"mtMet+I") echo "mtREV" ;;

        "mtVer"|"mtVer+F"|"mtVer+F+I"|"mtVer+F+R2") echo "mtREV" ;;

        "PMB") echo "PMB" ;;

        *) echo "$1" ;;  # Return the model as is if no mapping exists

    esac

}


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


    # Map the model to the RAxML-compatible equivalent

    corrected_model=$(map_model "$best_model")


    # Define the output prefix

    output_prefix="$output_dir/$base_name"


    # Run the RAxML-NG command and check for errors

    echo "Running RAxML-NG for $msa_file with model $corrected_model"

    raxml-ng --msa "$msa_file" --tree "$cladogram_file" --model "$corrected_model" --prefix "$output_prefix" --evaluate --seed 3

    raxml_exit_status=$?


    # Check if the output bestTree file was generated successfully

    if [[ $raxml_exit_status -ne 0 || ! -f "${output_prefix}.raxml.bestTree" ]]; then

        echo "Error: RAxML-NG failed for $msa_file. Moving files to $error_dir."


        # Copy the input file and log file (if exists) to the error directory

        cp "$msa_file" "$error_dir/"

        [[ -f "$model_log_file" ]] && cp "$model_log_file" "$error_dir/"

    else

        echo "Processed $msa_file with model $corrected_model and prefix $output_prefix"

    fi

done


echo "All files processed. Outputs are saved in $output_dir. Errors are in $error_dir."

