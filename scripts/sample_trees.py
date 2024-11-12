import math

import sys


def sample_trees(input_file, output_file, num_trees_to_select=4000):

    # Read the input file

    with open(input_file, 'r') as infile:

        lines = infile.readlines()


    # Identify where the trees start (usually after the species list and metadata)

    tree_start_index = 0

    for i, line in enumerate(lines):

        if line.startswith("tree "):  # Trees commonly start with 'tree '

            tree_start_index = i

            break


    # The header includes all lines before the first tree

    header = lines[:tree_start_index]

    last_line = lines[-1]  # Typically, there is a last line after the trees block


    # The actual tree data starts from tree_start_index

    trees = lines[tree_start_index:-1]

    total_trees = len(trees)


    # Calculate the interval for regular sampling

    interval = math.floor(total_trees / num_trees_to_select)


    # Select trees at regular intervals

    selected_trees = [trees[i] for i in range(0, total_trees, interval)][:num_trees_to_select]


    # Write the header, sampled trees, and the last line to the output file

    with open(output_file, 'w') as outfile:

        outfile.writelines(header)

        outfile.writelines(selected_trees)

        outfile.write(last_line)


    print(f"File with {num_trees_to_select} sampled trees created: {output_file}")


# Check if positional arguments are provided

if len(sys.argv) != 3:

    print("Usage: python script.py <input_file> <output_file>")

else:

    input_file = sys.argv[1]  # First argument: input file

    output_file = sys.argv[2]  # Second argument: output file

    sample_trees(input_file, output_file, num_trees_to_select=4000)

