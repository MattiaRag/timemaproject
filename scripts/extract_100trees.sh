#!/bin/bash

# Define the percentage of trees to exclude
percentage_to_exclude=0.10

# Read the Nexus file
input_file="treerun1/beastTIMEMAdefinitiveee2-trimmedDEFINITIVEspnames.trees"
output_file="output1.trees"

# Split the lines into three parts: lines_before_trees, trees_block, and lines_after_trees
lines_before_trees=$(head -n 72 "$input_file")
trees_block=$(tail -n +73 "$input_file" | head -n -1)  # Excludes the first 72 lines and the last line
last_line=$(tail -n 1 "$input_file")

# Convert trees_block into an array
IFS=$'\n' read -rd '' -a trees_array <<<"$trees_block"
num_trees=${#trees_array[@]}

# Calculate how many trees to exclude
num_trees_to_exclude=$(echo "$num_trees * $percentage_to_exclude" | bc)
num_trees_to_exclude=${num_trees_to_exclude%.*}  # Convert to an integer

# Exclude the first 10% of trees
trees_to_choose_from=("${trees_array[@]:num_trees_to_exclude}")

# Choose 50 trees randomly
chosen_trees=()
for i in $(seq 1 50); do
  random_index=$(shuf -i 0-$((${#trees_to_choose_from[@]}-1)) -n 1)
  chosen_trees+=("${trees_to_choose_from[$random_index]}")
done

# Concatenate the lines before trees, chosen trees, and the last line
output_lines=$(printf "%s\n" "$lines_before_trees")
output_lines+=$(printf "%s\n" "${chosen_trees[@]}")
output_lines+=$(printf "%s\n" "$last_line")

# Write the modified Nexus file
echo -e "$output_lines" > "$output_file"
