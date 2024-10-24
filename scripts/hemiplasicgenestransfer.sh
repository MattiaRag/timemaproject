#!/bin/bash


# Variables

names_file="part_1b/hemiplasy_genes/loci_names.fa"  # File containing the list of fasta filenames

fasta_directory="preliminary/orthogroupsdisco_aa"  # Directory containing the fasta files

output_directory="part_1b/hemiplasy_genes/hemiplasicgenes_seqs"  # Directory to copy the files to


# Create the output directory if it doesn't exist

mkdir -p "$output_directory"


# Read each file name from the file with fasta names

while IFS= read -r fasta_file_name; do

    # Construct the full path to the fasta file

    fasta_file_path="${fasta_directory}/${fasta_file_name}"


    # Check if the file exists

    if [[ -f "$fasta_file_path" ]]; then

        # Copy the file to the output directory

        cp "$fasta_file_path" "$output_directory/"

        echo "Copied $fasta_file_name to $output_directory."

    else

        echo "File $fasta_file_path not found, skipped."

    fi

done < "$names_file"


echo "Copying completed. Files have been copied to $output_directory"

