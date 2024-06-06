#!/bin/bash

# Path to AMAS.py
AMAS_PATH="scripts/AMAS.py"

# Create directories if they don't exist
mkdir -p part_1a/species_trees/sptree_aa/min_5sp/Renamed part_1a/species_trees/sptree_aa/min_5sp/Iqtreeinput part_1a/species_trees/sptree_aa/min_5sp/Iqtreeoutput
mkdir -p part_1a/species_trees/sptree_aa/min_10sp/Renamed part_1a/species_trees/sptree_aa/min_10sp/Iqtreeinput part_1a/species_trees/sptree_aa/min_10sp/Iqtreeoutput

# Copy all fasta files from preliminary/orthogroupsdisco_aa/Trimmed_aa to part_1a/species_trees/sptree_aa/min_5sp
cp preliminary/orthogroupsdisco_aa/Trimmed_aa/*.fa part_1a/species_trees/sptree_aa/min_5sp

# Loop through all files with .fa extension in the min_5sp directory
for i in part_1a/species_trees/sptree_aa/min_5sp/*.fa; do
    # Count the number of headers in the file
    num_headers=$(grep -c '^>' "$i")

    # If the number of headers is greater than or equal to 10
    if [ "$num_headers" -ge 10 ]; then
        # Copy the file to min_10sp directory
        cp "$i" part_1a/species_trees/sptree_aa/min_10sp/
    else
        echo "The file $i contains less than 10 headers. Skipping to the next step."
    fi
done

# Function to process files in a given directory
process_files() {
    local input_dir=$1
    local renamed_dir=$2
    local iqtreeinput_dir=$3
    local iqtreeoutput_dir=$4
    local concat_file=$5

    for i in "$input_dir"/*.fa; do
        # Rename the FASTA file headers using only the part before the underscore
        awk '/^>/{split($1, arr, "_"); print arr[1]; next} {print}' "$i" > "${renamed_dir}/$(basename "${i}").rename"
    done

    # Remove empty files from the renamed directory
    find "$renamed_dir" -type f -size 0 -delete

    # Concatenation of renamed files
    echo "Checking renamed files for concatenation in ${renamed_dir}..."
    renamed_files=$(find "${renamed_dir}" -type f -name '*.rename' -print)
    if [ -n "$renamed_files" ]; then
        echo "Concatenating renamed files in ${renamed_dir}"
        python "${AMAS_PATH}" concat -y nexus -i "${renamed_files}" -f fasta -d aa -t "${iqtreeinput_dir}/${concat_file}"
    else
        echo "There are no renamed files to concatenate in ${renamed_dir}."
    fi

    # Running IQ-TREE
    if [ -f "${iqtreeinput_dir}/${concat_file}" ]; then
        echo "Running IQ-TREE on the concatenated alignment ${iqtreeinput_dir}/${concat_file}"
        iqtree2 -m TESTNEW -bb 1000 -s "${iqtreeinput_dir}/${concat_file}" --prefix "${iqtreeoutput_dir}/$(basename "${concat_file}" .faa)" -nt AUTO
    else
        echo "The concatenated file ${iqtreeinput_dir}/${concat_file} does not exist. IQ-TREE will not be executed."
    fi
}

# Process files in min_5sp directory
process_files "part_1a/species_trees/sptree_aa/min_5sp" "part_1a/species_trees/sptree_aa/min_5sp/Renamed" "part_1a/species_trees/sptree_aa/min_5sp/Iqtreeinput" "part_1a/species_trees/sptree_aa/min_5sp/Iqtreeoutput" "timema_5sp.concat.faa"

# Process files in min_10sp directory
process_files "part_1a/species_trees/sptree_aa/min_10sp" "part_1a/species_trees/sptree_aa/min_10sp/Renamed" "part_1a/species_trees/sptree_aa/min_10sp/Iqtreeinput" "part_1a/species_trees/sptree_aa/min_10sp/Iqtreeoutput" "timema_10sp.concat.faa"
