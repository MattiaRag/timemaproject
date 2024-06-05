#!/bin/bash

directory="preliminary/Orthofinder/renamed_one/OrthoFinder/Results_May30/Gene_Trees"
output_file="preliminary/disco/input_disco.trees"

# Function to modify the tip names in the Newick tree
modify_tip_names() {
    local file=$1
    sed -E 's/aa_sequences_([^_]+_[^_]+_[^,_]+)/\1/g' "$file"
}

# Concatenate the contents of all Newick files in the directory into the output file
for file in "$directory"/*.txt; do
    # Modify the tip names and concatenate to the output file
    modify_tip_names "$file"
    echo ""
done > "$output_file"

echo "All Newick files have been merged into $output_file with modified tip names."

