import os

import random

import math


# Function to process a .trees file and return selected trees

def process_trees(input_file, percentage_to_exclude=0.10, num_trees_to_select=500):

    with open(input_file, 'r') as infile:

        lines = infile.readlines()


    # Identify where the trees start (usually marked by lines starting with 'tree')

    tree_start_index = 0

    for i, line in enumerate(lines):

        if line.startswith("tree "):

            tree_start_index = i

            break


    # Separate header (before trees) and the trees block

    header = lines[:tree_start_index]

    trees = lines[tree_start_index:-1]  # Skip the last line (assumed to be metadata or end block)

    last_line = lines[-1]


    # Calculate how many trees to exclude

    total_trees = len(trees)

    num_trees_to_exclude = math.ceil(total_trees * percentage_to_exclude)


    # Exclude the first 10% of trees and choose trees randomly

    trees_to_choose_from = trees[num_trees_to_exclude:]

    chosen_trees = random.sample(trees_to_choose_from, num_trees_to_select)


    return header, chosen_trees, last_line


# Function to combine the selected trees from two files

def combine_trees(file1, file2, output_file, num_trees_to_select=500):

    # Process the first file

    header1, chosen_trees1, last_line1 = process_trees(file1, num_trees_to_select=num_trees_to_select)


    # Process the second file

    _, chosen_trees2, _ = process_trees(file2, num_trees_to_select=num_trees_to_select)


    # Combine the trees into the output file

    with open(output_file, 'w') as outfile:

        outfile.writelines(header1)  # Write header from the first file

        outfile.writelines(chosen_trees1)  # Write trees from the first file

        outfile.writelines(chosen_trees2)  # Write trees from the second file

        outfile.write(last_line1)  # Write the last line from the first file


    print(f"Output written to {output_file}")


# Define file paths

file1 = "part_2a/beast/all_COIseqs/constcoal/beastTIMEMA_allCOI_COALCONST-trimmed_all_COIseqs_def-1.trees"

file2 = "part_2a/beast/all_COIseqs/constcoal/beastTIMEMA_allCOI_COALCONST-trimmed_all_COIseqs_def-2.trees"

output_file = "part_2a/beast/all_COIseqs/constcoal/extracted_1000.trees"


# Combine trees from both files into the final output

combine_trees(file1, file2, output_file)

