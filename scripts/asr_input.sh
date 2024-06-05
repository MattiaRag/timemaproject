#!/bin/bash

# Directory containing the .treefile files
directory="preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa"

# Output file
output_file="2a/asr/asr_input.txt"

# Clear the existing output file
> "$output_file"

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

