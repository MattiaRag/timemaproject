import re

import os

import pandas as pd


def parse_blast_output(file_path):

    """ Parse the BLAST output file into a list of tables """

    with open(file_path, 'r') as file:

        lines = file.readlines()


    tables = []

    current_table = []

    query_headers = []

    skip_intro = False  # Flag to skip the introductory rows like "Sequences producing significant alignments:" and header row

    header_found = False


    for line in lines:

        if line.startswith("Query #"):

            if current_table:

                tables.append((query_headers, current_table))

            query_headers = [line.strip()]  # Store the query header

            current_table = []  # Start a new table

            skip_intro = False  # Reset the flag for each query section

            header_found = False

        elif "Sequences producing significant alignments:" in line:

            skip_intro = True  # Set flag to skip this row and the next one (header)

        elif skip_intro and not header_found:

            # Skip the column header row that follows "Sequences producing significant alignments:"

            header_found = True

            continue

        elif re.search(r'\S+', line):  # Non-empty lines

            current_table.append(line.strip())

    

    if current_table:

        tables.append((query_headers, current_table))


    return tables


def extract_data_from_table(table_lines):

    """ Extract data from a BLAST table """

    rows = []

    for line in table_lines:

        # Only process lines that have actual data (skipping headers)

        if not line.startswith("Description") and not line.startswith("Scientific"):

            # Split based on multiple spaces (2 or more spaces as delimiters)

            columns = re.split(r'\s{2,}', line.strip())  


            # Check if the number of columns matches expected (10). If not, log the issue.

            if len(columns) < 10:

                print(f"Warning: Line may be split incorrectly: {line}")

            

            rows.append(columns)


    max_columns = max(len(row) for row in rows)

    column_names = ["Description", "Scientific Name", "Common Name", "Taxid", "Max Score", 

                    "Total Score", "Query Cover", "E Value", "Per. Ident", "Accession"]


    if max_columns > len(column_names):

        column_names.extend([f"Extra_{i}" for i in range(1, max_columns - len(column_names) + 1)])


    return pd.DataFrame(rows, columns=column_names[:max_columns])


def process_tables(file_name, tables):

    """ Process each table to extract the first valid row after 'unnamed' rows and group by species """

    results = {}


    for query_headers, table_lines in tables:

        df = extract_data_from_table(table_lines)


        # Exclude rows with "unnamed" or "uncharacterized" in the 'Description' column

        valid_rows = df.loc[~df['Description'].str.contains('unnamed|uncharacterized|hypothetical|Hypothetical', case=False)]


        # If there are no valid rows, skip this table

        if valid_rows.empty:

            continue


        # Get the first valid row after filtering

        best_row = valid_rows.iloc[0].copy()


        # Extract the species code from the query header

        match = re.search(r'Query #[^:]+:\s([A-Z]{3})', query_headers[0])

        if match:

            species_code = match.group(1)

        else:

            continue  # Skip if we can't find the species code


        # Add the file name to the result

        best_row.loc['Source File'] = file_name


        # Store the row in the results dictionary, grouped by species code

        if species_code not in results:

            results[species_code] = []

        results[species_code].append(best_row)


    return results


def process_all_files(directory):

    """ Process all BLAST files in the directory and group results by species """

    all_results = {}


    for file_name in os.listdir(directory):

        if file_name.endswith(".txt"):

            file_path = os.path.join(directory, file_name)

            tables = parse_blast_output(file_path)

            file_results = process_tables(file_name, tables)

            

            for species_code, rows in file_results.items():

                if species_code not in all_results:

                    all_results[species_code] = []

                all_results[species_code].extend(rows)


    return all_results


def save_results_to_excel(results, output_file):

    """ Save the results grouped by species to an Excel file with separate sheets """

    with pd.ExcelWriter(output_file) as writer:

        for species_code, rows in results.items():

            # Convert the list of rows to a DataFrame

            species_df = pd.DataFrame(rows)

            

            # Write each species to a separate sheet

            species_df.to_excel(writer, sheet_name=species_code, index=False)


# Run the script with the modified filtering and column alignment logic

if __name__ == "__main__":

    input_directory = "."  # Replace with your actual directory

    output_file = "blastedterms.xlsx"


    # Process all files and group by species

    results = process_all_files(input_directory)


    # Save the results to an Excel file with multiple sheets

    save_results_to_excel(results, output_file)

