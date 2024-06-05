#!/bin/bash

# Define the input directory for OrthoFinder
input_dir="preliminary/Orthofinder/renamed_one"

#Run OrthoFinder with the specified input and flag
orthofinder -f "$input_dir" -y

echo "OrthoFinder has been executed"

