#!/bin/bash

# Function to concatenate .treefile contents and run IQ-TREE
concat_and_run_iqtree() {
    local treefile_dir=$1
    local output_file=$2
    local concat_treefile=$3
    local iqtree_output_prefix=$4

    if [ -d "$treefile_dir" ] && [ "$(ls -A "$treefile_dir")" ]; then
        # Start with an empty file
        > "$output_file"

        # Concatenate .treefile contents
        for file in "$treefile_dir"/*.treefile; do
            cat "$file" | sed '/^\s*$/d' >> "$output_file"
        done

        echo "All files .treefile were concatenated into $output_file"

        # Run IQ-TREE
        iqtree2 -t "$concat_treefile" --gcf "$output_file" --prefix "$iqtree_output_prefix"
    else
        echo "No .treefile files to concatenate in $treefile_dir"
    fi
}

# Process AA min_5sp
concat_and_run_iqtree "part_1a/conc_factors/conc_f_aa/min_5sp" "part_1a/conc_factors/conc_f_aa/min_5sp/conc_factor_input.treefile" "part_1a/species_trees/sptree_aa/min_5sp/Iqtreeoutput/timema_5sp.concat.treefile" "part_1a/conc_factors/conc_f_aa/min_5sp/concord"
