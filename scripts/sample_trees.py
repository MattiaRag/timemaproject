import math


def sample_trees(input_file, output_file, num_trees_to_select=4000):

    with open(input_file, 'r') as infile:

        lines = infile.readlines()


    # Identify where the trees start (usually after the species list and metadata)

    tree_start_index = 0

    for i, line in enumerate(lines):

        if line.startswith("tree "):  # Commonly, trees start with 'tree '

            tree_start_index = i

            break


    # Header includes all lines before the first tree

    header = lines[:tree_start_index]

    last_line = lines[-1]  # Typically there is a last line after the trees block

    

    # The actual tree data starts from the tree_start_index

    trees = lines[tree_start_index:-1]

    total_trees = len(trees)


    # Calculate the interval for regular sampling

    interval = math.floor(total_trees / num_trees_to_select)


    # Select trees at regular intervals

    selected_trees = [trees[i] for i in range(0, total_trees, interval)][:num_trees_to_select]


    # Write the header, sampled trees, and last line to the output file

    with open(output_file, 'w') as outfile:

        outfile.writelines(header)

        outfile.writelines(selected_trees)

        outfile.write(last_line)

    

    print(f"File with {num_trees_to_select} sampled trees created: {output_file}")


# Parameters

input_file = "combined.trees"        # Replace with your .trees file name

output_file = "output_4000.trees" # Output file name


# Run the function to sample trees

sample_trees(input_file, output_file, num_trees_to_select=4000)

