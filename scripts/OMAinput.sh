#!/bin/bash

# Directory containing the .fa files
DIRECTORY="/home/STUDENTI/mattia.ragazzini/timemaproject/preliminary/orthogroupsdisco_aa"
# Name of the output file
OUTPUT_FILE="1b/OMA/OMAinput.fa"

# Create an empty output file
> "$OUTPUT_FILE"

# Loop through all .fa files in the directory
for FILE in "$DIRECTORY"/*.fa; do
  # Get the filename without the path
  FILENAME=$(basename "$FILE")
  # Get the filename without the extension
  BASENAME="${FILENAME%.fa}"
  
  # Read and modify headers, then write to the output file
  while IFS= read -r LINE; do
    if [[ $LINE == '>'* ]]; then
      echo ">${BASENAME}_${LINE:1}" >> "$OUTPUT_FILE"
    else
      echo "$LINE" >> "$OUTPUT_FILE"
    fi
  done < "$FILE"
done
