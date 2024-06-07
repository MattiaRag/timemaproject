#!/bin/bash

# Create target directories if they don't exist
mkdir -p part_1a/conc_factors/conc_f_aa/min_5sp part_1a/conc_factors/conc_f_aa/min_10sp
mkdir -p part_1a/conc_factors/conc_f_nu/min_5sp part_1a/conc_factors/conc_f_nu/min_10sp

# Copy all .treefile files to the respective min_5sp directories
if compgen -G "preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa/*.treefile" > /dev/null; then
    cp preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa/*.treefile part_1a/conc_factors/conc_f_aa/min_5sp
else
    echo "No .treefile files found in preliminary/orthogroupsdisco_aa/Iqtreeoutput_aa"
fi

if compgen -G "preliminary/orthogroupsdisco_nu/Iqtreeoutput_nu/*.treefile" > /dev/null; then
    cp preliminary/orthogroupsdisco_nu/Iqtreeoutput_nu/*.treefile part_1a/conc_factors/conc_f_nu/min_5sp
else
    echo "No .treefile files found in preliminary/orthogroupsdisco_nu/Iqtreeoutput_nu"
fi

# Function to filter .treefile files with at least 10 tips and copy them to min_10sp
filter_treefiles_with_min_10_tips() {
    local input_dir=$1
    local output_dir=$2

    for file in "$input_dir"/*.treefile; do
        if [ -f "$file" ]; then
            num_tips=$(grep -o 'T[A-Z][A-Z]:' "$file" | wc -l)
            if [ "$num_tips" -ge 10 ]; then
                cp "$file" "$output_dir"
            fi
        fi
    done
}

# Filter and copy files for AA
filter_treefiles_with_min_10_tips "part_1a/conc_factors/conc_f_aa/min_5sp" "part_1a/conc_factors/conc_f_aa/min_10sp"

# Filter and copy files for NU
filter_treefiles_with_min_10_tips "part_1a/conc_factors/conc_f_nu/min_5sp" "part_1a/conc_factors/conc_f_nu/min_10sp"

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

# Process AA min_10sp
concat_and_run_iqtree "part_1a/conc_factors/conc_f_aa/min_10sp" "part_1a/conc_factors/conc_f_aa/min_10sp/conc_factor_input.treefile" "part_1a/species_trees/sptree_aa/min_10sp/Iqtreeoutput/timema_10sp.concat.treefile" "part_1a/conc_factors/conc_f_aa/min_10sp/concord"

# Process NU min_5sp
concat_and_run_iqtree "part_1a/conc_factors/conc_f_nu/min_5sp" "part_1a/conc_factors/conc_f_nu/min_5sp/conc_factor_input.treefile" "part_1a/species_trees/sptree_nu/min_5sp/Iqtreeoutput/timema_5sp.concat.treefile" "part_1a/conc_factors/conc_f_nu/min_5sp/concord"

# Process NU min_10sp
concat_and_run_iqtree "part_1a/conc_factors/conc_f_nu/min_10sp" "part_1a/conc_factors/conc_f_nu/min_10sp/conc_factor_input.treefile" "part_1a/species_trees/sptree_nu/min_10sp/Iqtreeoutput/timema_10sp.concat.treefile" "part_1a/conc_factors/conc_f_nu/min_10sp/concord"
