#!/bin/bash

# Directory containing the FASTA files
input_directory="preliminary/AGAT/aminoacids/renamed_headers_aa"
output_directory="preliminary/AGAT/aminoacids/renamed_one"

# Create output directory if it does not exist
mkdir -p "$output_directory"

# Iterate through each FASTA file in the input directory
for fasta_file in "$input_directory"/*.fasta; do
    # Get the base name of the file
    base_name=$(basename "$fasta_file")
    output_file="$output_directory/$base_name"

    # Process the file and convert it to one-line format
    awk '/^>/ {if (seq) print seq; print $0; seq=""} !/^>/ {seq=seq $0} END {if (seq) print seq}' "$fasta_file" > "$output_file"
done

echo "Conversion complete. One-line FASTA files are in $output_directory"
