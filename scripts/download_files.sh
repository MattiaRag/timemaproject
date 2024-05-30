#!/bin/bash

# Define the path to the TSV file
tsv_file="scripts/downloading_links.tsv"

# Define the output directory for downloaded files
output_dir="preliminary/AGAT/docs1"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Read the TSV file and download the files
while IFS=$'\t' read -r filetype url; do
    # Extract the filename from the URL
    filename=$(basename "${url%%\?*}")

    # Download the file and save it to the output directory
    wget -O "${output_dir}/${filename}" "$url"
done < "$tsv_file"

echo "All files have been downloaded to $output_dir"

