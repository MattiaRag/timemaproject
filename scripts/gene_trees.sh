#!/bin/bash

# Base directories
base_dir="preliminary"
nu_dir="${base_dir}/orthogroupsdisco_nu"
aa_dir="${base_dir}/orthogroupsdisco_aa"
maff="${base_dir}/orthogroupsdisco_aa/Maffted"
Tr_aa="${base_dir}/orthogroupsdisco_aa/Trimmed_aa"
Tr_nu="${base_dir}/orthogroupsdisco_nu/Trimmed_nu"
Iqin_aa="${base_dir}/orthogroupsdisco_aa/Iqtreeinput_aa"
Iqin_nu="${base_dir}/orthogroupsdisco_nu/Iqtreeinput_nu"
ls_aa="${base_dir}/orthogroupsdisco_aa/lessthan5headers_aa"
ls_nu="${base_dir}/orthogroupsdisco_nu/lessthan5headers_nu"
iqout_aa="${base_dir}/orthogroupsdisco_aa/Iqtreeoutput_aa"
iqout_nu="${base_dir}/orthogroupsdisco_nu/Iqtreeoutput_nu"

# Create base directories if they don't exist
mkdir -p "$maff" "$Tr_aa" "$Tr_nu" "$Iqin_aa" "$Iqin_nu" "$ls_aa" "$ls_nu" "$iqout_aa" "$iqout_nu"

# Loop through all .fa files in the amino acid orthogroups directory
for i in "$aa_dir"/*.fa; do
    base_name=$(basename "$i" .fa)

    # Perform sequence alignment using MAFFT with automatic settings
    mafft --auto "$i" > "$maff/${base_name}.mafft.fa"

    # Perform trimming of the alignment with trimAl, considering residue overlap and sequence overlap, and removing gappy regions
    trimal -in "$maff/${base_name}.mafft.fa" -resoverlap 0.5 -seqoverlap 50 -gappyout > "$Tr_aa/${base_name}.trimmed.fa"
    trimal -in "$maff/${base_name}.mafft.fa" -resoverlap 0.5 -seqoverlap 50 -gappyout -ignorestopcodon -backtrans "$nu_dir/${base_name}.fa" > "$Tr_nu/${base_name}.trimmed.fa"

    # Process amino acid trimmed file
    if [ -s "$Tr_aa/${base_name}.trimmed.fa" ]; then
        # Rename the headers in the trimmed file, keeping only the part before the underscore
        awk '/^>/{split($1, arr, "_"); print arr[1]; next} {print}' "$Tr_aa/${base_name}.trimmed.fa" > "$Iqin_aa/${base_name}.input.fa"

        # Count headers in the input file for IQ-TREE
        header_count_aa=$(grep -c "^>" "$Iqin_aa/${base_name}.input.fa")

        # Check if the input file has at least 5 headers
        if [ "$header_count_aa" -ge 5 ]; then
            # Run IQ-TREE on the input file with enough headers, setting the prefix for output files and determining the number of threads automatically
            iqtree2 -s "$Iqin_aa/${base_name}.input.fa" --prefix "$iqout_aa/loci_${base_name}" -T 8 &
        else
            # Move files with less than 5 headers to a separate folder
            mv "$Iqin_aa/${base_name}.input.fa" "$ls_aa/"
            echo "$i has less than 5 headers and was moved to lessthan5headers folder."
        fi
    else
        echo "$Tr_aa/${base_name}.trimmed.fa is empty."
    fi

    # Process nucleotide trimmed file
    if [ -s "$Tr_nu/${base_name}.trimmed.fa" ]; then
        # Rename the headers in the trimmed file, keeping only the part before the underscore
        awk '/^>/{split($1, arr, "_"); print arr[1]; next} {print}' "$Tr_nu/${base_name}.trimmed.fa" > "$Iqin_nu/${base_name}.input.fa"

        # Count headers in the input file for IQ-TREE
        header_count_nu=$(grep -c "^>" "$Iqin_nu/${base_name}.input.fa")

        # Check if the input file has at least 5 headers
        if [ "$header_count_nu" -ge 5 ]; then
            # Run IQ-TREE on the input file with enough headers, setting the prefix for output files and determining the number of threads automatically
            iqtree2 -s "$Iqin_nu/${base_name}.input.fa" --prefix "$iqout_nu/loci_${base_name}" -T 8
        else
            # Move files with less than 5 headers to a separate folder
            mv "$Iqin_nu/${base_name}.input.fa" "$ls_nu/"
            echo "$i has less than 5 headers and was moved to lessthan5headers folder."
        fi
    else
        echo "$Tr_nu/${base_name}.trimmed.fa is empty."
    fi
done

echo "Processing complete."
