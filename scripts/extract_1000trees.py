import os

import math

import sys


# Function to process a .trees file and return selected trees

def process_trees(input_file, percentage_to_exclude=0.10, num_trees_to_select=1000):

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


    # Exclude the first 10% of trees and select 1000 trees at regular intervals

    trees_to_choose_from = trees[num_trees_to_exclude:]

    interval = max(1, len(trees_to_choose_from) // num_trees_to_select)


    # Select trees at regular intervals

    chosen_trees = trees_to_choose_from[::interval][:num_trees_to_select]


    return header, chosen_trees, last_line


# Function to combine the selected trees from two files

def combine_trees(file1, file2, output_file, num_trees_to_select=1000):

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


# Check if the correct number of arguments is provided

if len(sys.argv) != 4:

    print("Usage: python script.py <input_file1> <input_file2> <output_file>")

else:

    file1 = sys.argv[1]  # First input file

    file2 = sys.argv[2]  # Second input file

    output_file = sys.argv[3]  # Output file

    combine_trees(file1, file2, output_file)

