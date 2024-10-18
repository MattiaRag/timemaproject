#!/bin/bash


# Variables

names_file="part_1b/hemiplasy_genes/loci_names.fa"  # File containing the list of fasta filenames

fasta_directory="preliminary/orthogroupsdisco_aa"  # Replace with the path to the directory containing the fasta files

output_file="part_1b/hemiplasy_genes/merged_sequences.fasta"  # Name of the final output file


# Create or empty the output file

> "$output_file"


# Read each file name from the file with fasta names

while IFS= read -r fasta_file_name; do

    # Construct the full path to the fasta file

    fasta_file_path="${fasta_directory}/${fasta_file_name}"


    # Check if the file exists

    if [[ -f "$fasta_file_path" ]]; then

        # Read the file content and modify the headers

        awk -v filename="$fasta_file_name" '/^>/ {print $0"_"filename} !/^>/ {print $0}' "$fasta_file_path" >> "$output_file"

    else

        echo "File $fasta_file_path not found, skipped."

    fi

done < "$names_file"


echo "Merging completed. The file has been saved as $output_file"

