#!/bin/bash

# List of file prefixes
prefixes=("Tbi" "Tce" "Tcm" "Tdi" "Tge" "Tms" "Tpa" "Tps" "Tsi" "Tte")

# Base directories
base_dir="preliminary/AGAT"
nu_dir="${base_dir}/nucleotides"
aa_dir="${base_dir}/aminoacids"
longest_gff_dir="${base_dir}/docs/longest_isoforms_gff"

# Create base directories if they don't exist
mkdir -p "$nu_dir"
mkdir -p "$aa_dir"
mkdir -p "$longest_gff_dir"

# Iterate through each prefix to process the files
for prefix in "${prefixes[@]}"; do

    # Define the input GFF and FASTA files
    gff_file="${base_dir}/docs/${prefix}_b3v08.max_arth_b2g_droso_b2g.gff?download=1"
    fasta_file="${base_dir}/docs/${prefix}_b3v08.fasta?download=1"

    # Remove the '?download=1' part for the output file names
    gff_file_cleaned="${gff_file%\?download=1}"
    fasta_file_cleaned="${fasta_file%\?download=1}"

    # Rename the files to remove '?download=1' part if they haven't been cleaned yet
    if [ ! -f "$gff_file_cleaned" ]; then
        mv "$gff_file" "$gff_file_cleaned"
    fi

    if [ ! -f "$fasta_file_cleaned" ]; then
        mv "$fasta_file" "$fasta_file_cleaned"
    fi

    # Define the output GFF file after keeping only the longest isoform
    longest_isoform_gff="${longest_gff_dir}/${prefix}_longest_isoform.gff"

    # Run agat_sp_keep_longest_isoform.pl to keep only the longest isoform
    echo "Running agat_sp_keep_longest_isoform.pl for $prefix"
    agat_sp_keep_longest_isoform.pl -gff "$gff_file_cleaned" -o "$longest_isoform_gff"

    # Extract the nucleotide sequences using the processed GFF file
    nu_output_file="${nu_dir}/nu_sequences_${prefix}.fasta"
    echo "Extracting nucleotide sequences for $prefix"
    agat_sp_extract_sequences.pl --gff "$longest_isoform_gff" --fasta "$fasta_file_cleaned" --type CDS --cfs --output "$nu_output_file"

    # Extract the protein sequences using the processed GFF file
    aa_output_file="${aa_dir}/aa_sequences_${prefix}.fasta"
    echo "Extracting protein sequences for $prefix"
    agat_sp_extract_sequences.pl --gff "$longest_isoform_gff" --fasta "$fasta_file_cleaned" --type CDS -p --cfs --output "$aa_output_file"

    echo "Processed: $prefix"
done

echo "All processing complete."
