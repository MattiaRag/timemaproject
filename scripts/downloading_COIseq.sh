#!/bin/bash

# List of NCBI URLs to download sequences from
urls=(
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474330.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474260.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410137.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF005332.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410118.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410135.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410129.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410132.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410099.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410101.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410063.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410044.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF409998.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410060.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410151.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410150.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=AF410145.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=KT426628.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=KT426640.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474312.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474331.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=MN365010.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474276.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474282.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474324.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474291.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=FJ474284.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=KP300914.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=KT426637.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=JQ907057.1&db=nuccore&report=fasta&retmode=txt"
    "https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=KC014542.1&db=nuccore&report=fasta&retmode=txt"
)

# Output file
output_file="part_2a/beast/COI_sequences.fasta"

# Create an empty output file
> "$output_file"

# Loop through each URL, download the sequence, and format the header
for url in "${urls[@]}"; do
    content=$(wget -qO- "$url")
    
    if [[ $content == *">"* ]]; then
        header=$(echo "$content" | grep ">" | sed 's/>//')
        sequence=$(echo "$content" | grep -v ">" | tr -d '\n')

        # Extract genus and species from the header
        genus_species=$(echo "$header" | awk '{print $2, $3}')

        # Append to the output file
        if [[ -n $genus_species ]]; then
            echo ">$genus_species" >> "$output_file"
            echo "$sequence" >> "$output_file"
        else
            echo "Error: Failed to extract genus and species from header: $header"
        fi
    else
        echo "Error: Failed to retrieve sequence from $url"
    fi
done
