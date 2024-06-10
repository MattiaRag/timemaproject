#!/bin/bash

# Directory containing the .treefile files
directory_aa="preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa"
directory_nu="preliminary/orthogroupsdisco_nu/Iqtreeoutput_nu"

# Output files
output_file_aa="part_2a/asr/fitch_asr_input_aa.txt"
output_file_nu="part_2a/asr/asr_input_nu.txt"

# Clear the existing output files
> "$output_file_aa"
> "$output_file_nu"

# Function to process a directory and output file
process_directory() {
    local directory=$1
    local output_file=$2

    # Loop through all .treefile files in the directory
    for file in "$directory"/*.treefile
    do
        if [ -f "$file" ]; then
            # Extract the base name of the file without the extension
            filename=$(basename "$file" .treefile)

            # Read the content of the file
            content=$(cat "$file")

            # Write the filename and content to the output file
            echo -e "${filename}\t${content}" >> "$output_file"
        fi
    done
}

# Process the directories
process_directory "$directory_aa" "$output_file_aa"
process_directory "$directory_nu" "$output_file_nu"
