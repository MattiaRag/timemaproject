from ete3 import Tree

import os

import glob

import re

import sys


# Define the directory where the input files are located

input_dir = os.path.join(os.getcwd(), "preliminary/orthogroupsdisco_aa/Iqtreeinput_aa")


# List files with .input.fa extension in the specified input directory

print(f"Searching for input files in: {input_dir}")

file_list = glob.glob(os.path.join(input_dir, '*.input.fa'))


if not file_list:

    print("Error: No .input.fa files found in the specified directory.")

    sys.exit(1)

else:

    print(f"Found {len(file_list)} input files.")


# Check if the unrooted species tree file is provided

if len(sys.argv) != 2:

    print("Usage: python pruner.py unrooted_cladogram.nwk")

    sys.exit(1)


unrooted_cladogram = sys.argv[1]


if not os.path.exists(unrooted_cladogram):

    print(f"Error: Unrooted cladogram file '{unrooted_cladogram}' not found.")

    sys.exit(1)

else:

    print(f"Unrooted cladogram file '{unrooted_cladogram}' loaded successfully.")


# Pruning

for idx, path in enumerate(file_list, start=1):

    print(f"\nProcessing file {idx}/{len(file_list)}: {os.path.basename(path)}")

    

    try:

        # Load the unrooted reference tree

        species_tree = Tree(unrooted_cladogram, format=1)

        print("  - Unrooted reference tree loaded successfully.")

    except Exception as e:

        print(f"  - Error loading unrooted reference tree: {e}")

        continue


    # Generate output file name

    base_name, _ = os.path.splitext(os.path.basename(path))

    pruned_tree = os.path.join(input_dir, base_name + "_cladogram.nwk")


    # Extract species names from the .input.fa file headers

    try:

        with open(path, "r") as fasta_file:

            # Extract lines starting with '>' and get species names using regex

            headers = [line.strip() for line in fasta_file if line.startswith(">")]

            pattern = r">([A-Z]{3})"  # Match three uppercase letters in header

            leaves = [re.match(pattern, header).group(1) for header in headers if re.match(pattern, header)]

        if not leaves:

            print("  - Warning: No valid species names found in the input file.")

        else:

            print(f"  - Found {len(leaves)} species in the input file: {', '.join(leaves)}")

    except Exception as e:

        print(f"  - Error reading input file: {e}")

        continue


    # Prune the unrooted reference tree

    try:

        original_leaves = set(species_tree.get_leaf_names())  # Get all species in the reference tree

        valid_leaves = [leaf for leaf in leaves if leaf in original_leaves]  # Keep only valid species

        missing_leaves = [leaf for leaf in leaves if leaf not in original_leaves]  # Identify missing species


        if missing_leaves:

            print(f"  - Warning: Species not found in reference tree: {', '.join(missing_leaves)}")


        species_tree.prune(valid_leaves)


        # Ensure the pruned tree remains unrooted

        species_tree.unroot()

        print("  - Reference tree pruned and unrooted successfully.")

    except Exception as e:

        print(f"  - Error pruning the reference tree: {e}")

        continue


    # Write the pruned tree to a new file

    try:

        species_tree.write(format=9, outfile=pruned_tree)

        print(f"  - Pruned tree saved to: {pruned_tree}")

    except Exception as e:

        print(f"  - Error saving the pruned tree: {e}")


print("\nProcessing completed.")

