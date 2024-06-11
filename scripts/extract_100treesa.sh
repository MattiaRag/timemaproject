#!/bin/bash

# Define the percentage of trees to exclude
percentage_to_exclude=0.10
num_trees_to_select=50

process_trees() {
    local input_file=$1
    local temp_file=$(mktemp)

    # Read the file and separate header, trees block, and last line
    header=$(head -n 72 "$input_file")
    trees=$(sed -n '73,$p' "$input_file" | head -n -1)
    last_line=$(tail -n 1 "$input_file")

    # Calculate how many trees to exclude
    total_trees=$(echo "$trees" | wc -l)
    num_trees_to_exclude=$(echo "$total_trees * $percentage_to_exclude" | bc | awk '{print int($1+0.5)}')

    # Exclude the first 10% of trees
    trees_to_choose_from=$(echo "$trees" | tail -n +$((num_trees_to_exclude + 1)))

    # Choose 50 trees randomly
    chosen_trees=$(echo "$trees_to_choose_from" | shuf -n $num_trees_to_select)

    # Write the selected trees to the temporary file
    echo "$header" > "$temp_file"
    echo "$chosen_trees" >> "$temp_file"
    echo "$last_line" >> "$temp_file"

    echo "$temp_file"
}

# Process the files and get the paths to temporary files
file1=$(process_trees "part_2a/beast/treerun1/beastTIMEMA.trees")
file2=$(process_trees "part_2a/beast/treerun2/beastTIMEMA.trees")

# Combine the chosen trees from both files into the final output
output_file="part_2a/beast/extracted_100.trees"

# Get the header from the first file
head -n 72 "$file1" > "$output_file"

# Concatenate the chosen trees from both files
sed -n '73,$p' "$file1" | head -n -1 >> "$output_file"
sed -n '73,$p' "$file2" | head -n -1 >> "$output_file"

# Add the last line from the first file to the output
tail -n 1 "$file1" >> "$output_file"

# Clean up temporary files
rm "$file1" "$file2"

echo "Output written to $output_file"
