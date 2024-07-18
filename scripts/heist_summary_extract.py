import os

import re

import sys


def extract_info_from_file(file_path):

    with open(file_path, 'r') as file:

        content = file.read()

    

    # Regex patterns to extract the required values

    full_hemiplasy_pattern = re.compile(r'"True" hemiplasy \(1 mutation\) occurs \[(\d+)\] time\(s\)')

    some_hemiplasy_pattern = re.compile(r'Combinations of hemiplasy and homoplasy \(1 < # mutations < 5\) occur \[(\d+)\] time\(s\)')

    full_homoplasy_pattern = re.compile(r'"True" homoplasy \(>= 5 mutations\) occurs \[(\d+)\] time\(s\)')

    

    full_hemiplasy = full_hemiplasy_pattern.search(content)

    some_hemiplasy = some_hemiplasy_pattern.search(content)

    full_homoplasy = full_homoplasy_pattern.search(content)

    

    return (

        int(full_hemiplasy.group(1)) if full_hemiplasy else 0,

        int(some_hemiplasy.group(1)) if some_hemiplasy else 0,

        int(full_homoplasy.group(1)) if full_homoplasy else 0

    )


def main(summary_directory, output_file):

    # Open the output file for writing

    with open(output_file, 'w') as out_file:

        out_file.write("File\tFull_hemiplasy\tSome_hemiplasy\tFull_homoplasy\n")

        

        # Iterate over files in the summary directory

        for filename in os.listdir(summary_directory):

            if filename.endswith('_summary.txt'):

                file_path = os.path.join(summary_directory, filename)

                full_hemiplasy, some_hemiplasy, full_homoplasy = extract_info_from_file(file_path)

                

                # Write the extracted information to the output file

                out_file.write(f"{filename}\t{full_hemiplasy}\t{some_hemiplasy}\t{full_homoplasy}\n")


if __name__ == "__main__":

    # Check if the correct number of arguments is provided

    if len(sys.argv) != 3:

        print("Usage: python extract_summary.py <summary_directory> <output_file>")

        sys.exit(1)

    

    summary_directory = sys.argv[1]

    output_file = sys.argv[2]

    

    # Check if the provided summary directory exists

    if not os.path.isdir(summary_directory):

        print(f"The provided directory {summary_directory} does not exist.")

        sys.exit(1)

    

    # Run the main function with the provided arguments

    main(summary_directory, output_file)

