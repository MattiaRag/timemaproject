#!/bin/bash

# Directories containing the FASTA files
aminoacids_dir="preliminary/AGAT/aminoacids"
nucleotides_dir="preliminary/AGAT/nucleotides"

# Output directories for the modified FASTA files
output_dir_aa="${aminoacids_dir}/renamed_headers_aa"
output_dir_nu="${nucleotides_dir}/renamed_headers_nu"

# Create the output directories if they don't exist
mkdir -p "$output_dir_aa"
mkdir -p "$output_dir_nu"

# Function to process FASTA files and modify headers
process_fasta_files() {
    local input_dir=$1
    local output_dir=$2

    # Iterate over each FASTA file in the directory
    for fasta_file in "$input_dir"/*.fasta; do
        # Output file name
        output_file="${output_dir}/$(basename "$fasta_file")"

        # Modify the headers in the FASTA file
        awk '/^>/ {print $1; next} {print}' "$fasta_file" > "$output_file"

        echo "Processed: $(basename "$fasta_file")"
    done
}

# Process the aminoacids directory
process_fasta_files "$aminoacids_dir" "$output_dir_aa"

# Process the nucleotides directory
process_fasta_files "$nucleotides_dir" "$output_dir_nu"

echo "All files have been processed."

