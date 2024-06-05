#!/bin/bash
name=0

# Create output directory if it does not exist
mkdir -p "preliminary/orthogroupsdisco_aa"

# Iterate over each line in the input file
while IFS= read -r line; do
    name=$((name+1))
    output_file="preliminary/orthogroupsdisco_aa/${name}.fa"
   
    echo "Processing line $name: $line"
   
    # Extract the identifiers from the current line using grep
    echo "$line" | grep -o "[A-Za-z]\{3\}_[A-Z]\{3\}_[0-9]\{5\}-R[A-Z]" | while IFS= read -r full_id; do
        if [ -z "$full_id" ]; then
            echo "No identifier found in line: $line"
            continue
        fi

        echo "Full identifier: $full_id"

        # Remove the first part to get the desired identifier
        id=$(echo "$full_id" | sed 's/^[A-Za-z]\{3\}_//')

        if [ -z "$id" ]; then
            echo "Failed to extract ID from full identifier: $full_id"
            continue
        fi

        echo "Extracted ID: $id"

        # Extract the prefix to determine the file name to look for
        prefix=$(echo "$full_id" | cut -d '_' -f1)
        fasta_file="preliminary/AGAT/aminoacids/renamed_one/aa_sequences_${prefix}.fasta"

        if [ ! -f "$fasta_file" ]; then
            echo "FASTA file not found: $fasta_file"
            continue
        fi

        echo "FASTA file: $fasta_file"

        # Look for the identifier in the corresponding file
        grep_output=$(grep -A 1 "$id" "$fasta_file")

        if [ -z "$grep_output" ]; then
            echo "Identifier $id not found in $fasta_file"
        else
            echo "$grep_output" >> "$output_file"
            echo "Processed identifier $id from $fasta_file"
        fi
    done

    # Check if any identifiers were processed for this line
    if [ ! -s "$output_file" ]; then
        echo "No identifiers processed for line $name"
    fi
done < "preliminary/disco/discooutputDEF5.trees"

echo "Processing complete."
