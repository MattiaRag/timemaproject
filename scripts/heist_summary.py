import os

import re

import sys

from collections import defaultdict


# Function to extract results from a file

def extract_results(file_path):

    # Regex pattern to match the results section in the file

    results_pattern = re.compile(r'### RESULTS ###(.*?)### OBSERVED GENE TREES ###', re.DOTALL)

    

    # Read the content of the file

    with open(file_path, 'r') as file:

        content = file.read()

    

    # Search for the results section in the file content

    results_section = results_pattern.search(content)

    if results_section:

        results_section = results_section.group(1)

        

        # Initialize dictionaries to store the values

        values = defaultdict(int)

        taxa_values = defaultdict(lambda: [0, 0, 0])


        # Patterns to extract general values

        general_patterns = [

            (r'(\d+) loci matched the species character states', 0),

            (r'"True" hemiplasy \(1 mutation\) occurs (\d+) time\(s\)', 1),

            (r'Combinations of hemiplasy and homoplasy \(1 < # mutations < 5\) occur (\d+) time\(s\)', 2),

            (r'"True" homoplasy \(>= 5 mutations\) occurs (\d+) time\(s\)', 3),

            (r'(\d+) loci have a discordant gene tree', 4),

            (r'(\d+) loci are concordant with the species tree', 5),

            (r'(\d+) loci originate from an introgressed history', 6),

            (r'(\d+) loci originate from the species history', 7),

        ]


        # Extract general values based on the patterns

        for pattern, idx in general_patterns:

            match = re.search(pattern, results_section)

            if match:

                values[idx] += int(match.group(1))


        # Patterns to extract variable sections

        all_trees_pattern = re.compile(r'On all trees:\s*(.*?)\n\n', re.DOTALL)

        discordant_trees_pattern = re.compile(r'On discordant trees:\s*(.*?)\n\n', re.DOTALL)

        taxa_pattern = re.compile(r'Taxa (\d+)\s+(\d+)\s+(\d+)\s+(\d+)')


        # Extract values for "On all trees" section

        all_trees_section = all_trees_pattern.search(results_section)

        if all_trees_section:

            all_trees_lines = all_trees_section.group(1).strip().split('\n')

            for line in all_trees_lines:

                parts = re.split(r'\s+', line.strip())

                if len(parts) == 2:

                    mutations, count = map(int, parts)

                    if mutations <= 4:

                        values[8 + mutations - 1] += count  # Adjusting index to match the template


        # Extract values for "On discordant trees" section

        discordant_trees_section = discordant_trees_pattern.search(results_section)

        if discordant_trees_section:

            discordant_trees_lines = discordant_trees_section.group(1).strip().split('\n')

            for line in discordant_trees_lines:

                parts = re.split(r'\s+', line.strip())

                if len(parts) == 2:

                    mutations, count = map(int, parts)

                    if mutations <= 4:

                        values[12 + mutations - 1] += count  # Adjusting index to match the template


        # Extract values for taxa sections

        for match in taxa_pattern.finditer(results_section):

            taxa, tip, internal, reversal = map(int, match.groups())

            taxa_values[taxa][0] += tip

            taxa_values[taxa][1] += internal

            taxa_values[taxa][2] += reversal


        return values, taxa_values

    else:

        print(f"No results section found in {file_path}")

    return {}, {}


# Function to sum the extracted values

def sum_values(values_list, taxa_values_list):

    summed_values = defaultdict(int)

    summed_taxa_values = defaultdict(lambda: [0, 0, 0])


    # Sum general values

    for values in values_list:

        for key, value in values.items():

            summed_values[key] += value


    # Sum taxa values

    for taxa_values in taxa_values_list:

        for taxa, values in taxa_values.items():

            for i in range(3):

                summed_taxa_values[taxa][i] += values[i]


    return summed_values, summed_taxa_values


# Function to write the summed results to a file

def write_summed_results(summed_values, summed_taxa_values, output_file):

    # Template for the results output

    results_template = """### RESULTS ###


[{0}] loci matched the species character states


"True" hemiplasy (1 mutation) occurs [{1}] time(s)


Combinations of hemiplasy and homoplasy (1 < # mutations < 5) occur [{2}] time(s)


"True" homoplasy (>= 5 mutations) occurs [{3}] time(s)


[{4}] loci have a discordant gene tree

[{5}] loci are concordant with the species tree


[{6}] loci originate from an introgressed history

[{7}] loci originate from the species history


Distribution of mutation counts:


# Mutations\t# Trees

On all trees:

1\t\t[{8}]

2\t\t[{9}]

3\t\t[{10}]

4\t\t[{11}]


On concordant trees:

# Mutations\t# Trees


On discordant trees:

# Mutations\t# Trees

1\t\t[{12}]

2\t\t[{13}]

3\t\t[{14}]

4\t\t[{15}]


Origins of mutations leading to observed character states for hemiplasy + homoplasy cases:


\tTip mutation\tInternal branch mutation\tTip reversal

{taxa_results}

"""


    # Format the taxa results

    taxa_results = ""

    for taxa in sorted(summed_taxa_values.keys()):

        taxa_results += f"Taxa {taxa}\t[{summed_taxa_values[taxa][0]}]\t[{summed_taxa_values[taxa][1]}]\t[{summed_taxa_values[taxa][2]}]\n"


    # Format the final results output

    formatted_results = results_template.format(

        summed_values[0], summed_values[1], summed_values[2], summed_values[3],

        summed_values[4], summed_values[5], summed_values[6], summed_values[7],

        summed_values[8], summed_values[9], summed_values[10], summed_values[11],

        summed_values[12], summed_values[13], summed_values[14], summed_values[15],

        taxa_results=taxa_results.strip()

    )

    

    # Write the formatted results to the output file

    with open(output_file, 'w') as file:

        file.write(formatted_results)


# Main function to process directories and extract, sum, and write results

def main(input_directory):

    # Create the output directory name dynamically based on the input directory name

    summary_dir = os.path.join(os.path.dirname(input_directory), f"{os.path.basename(input_directory)}_summary")

    os.makedirs(summary_dir, exist_ok=True)

    

    # Iterate over subdirectories in the input directory

    for subdir in os.listdir(input_directory):

        subdir_path = os.path.join(input_directory, subdir)

        if os.path.isdir(subdir_path) and subdir.startswith('min_'):

            # Iterate over heist subdirectories in each min_* directory

            for heist_subdir in os.listdir(subdir_path):

                heist_subdir_path = os.path.join(subdir_path, heist_subdir)

                if os.path.isdir(heist_subdir_path) and heist_subdir.startswith('heist_'):

                    all_values = []

                    all_taxa_values = []


                    # Iterate over run directories in each heist_* directory

                    for run_dir in os.listdir(heist_subdir_path):

                        run_dir_path = os.path.join(heist_subdir_path, run_dir)

                        if os.path.isdir(run_dir_path) and run_dir.startswith('run_'):

                            # Iterate over txt files in each run_* directory

                            for file in os.listdir(run_dir_path):

                                if file.endswith('txt.txt'):

                                    file_path = os.path.join(run_dir_path, file)

                                    values, taxa_values = extract_results(file_path)

                                    if values:

                                        all_values.append(values)

                                        all_taxa_values.append(taxa_values)

                                        print(f"Extracted values from {file_path}: {values}")

                                        print(f"Extracted taxa values from {file_path}: {taxa_values}")


                    # If no values were extracted, skip to the next directory

                    if not all_values:

                        print(f"No values extracted for {heist_subdir}.")

                        continue


                    # Sum the extracted values

                    summed_values, summed_taxa_values = sum_values(all_values, all_taxa_values)

                    print(f"Summed values for {heist_subdir}: {summed_values}")

                    print(f"Summed taxa values for {heist_subdir}: {summed_taxa_values}")

                    

                    # Create the output file path and write the summed results

                    output_file = os.path.join(summary_dir, f'{subdir}_{heist_subdir}_summary.txt')

                    write_summed_results(summed_values, summed_taxa_values, output_file)


if __name__ == "__main__":

    # Ensure the script is called with one argument

    if len(sys.argv) != 2:

        print("Usage: python summary.py <input_directory>")

        sys.exit(1)

    

    # Get the input directory from the command line arguments

    input_directory = sys.argv[1]

    

    # Check if the provided directory exists

    if not os.path.isdir(input_directory):

        print(f"The provided directory {input_directory} does not exist.")

        sys.exit(1)


    # Run the main function

    main(input_directory)

