#!/bin/bash

# Output file for the combined FASTA sequences
output_file="part_2a/beast/COI_sequences.fasta"

# List of accession numbers with genus and species names
accession_names=(
    "Xeroderus_sp_FJ474330.1"
    "Agathemera_sp_FJ474260.1"
    "Timema_boharti_AF410137.1"
    "Timema_chumash_AF005332.1"
    "Timema_podura_AF410118.1"
    "Timema_tahoe_AF410135.1"
    "Timema_genevieve_AF410129.1"
    "Timema_bartmani_AF410132.1"
    "Timema_cristinae_AF410099.1"
    "Timema_monikensis_AF410101.1"
    "Timema_shepardii_AF410063.1"
    "Timema_douglasi_AF410044.1"
    "Timema_poppensis_AF409998.1"
    "Timema_californicum_AF410060.1"
    "Timema_petita_AF410151.1"
    "Timema_landelsensis_AF410150.1"
    "Timema_knulli_AF410145.1"
    "Diapherodes_venustula_KT426628.1"
    "Pseudophasma_subapterum_KT426640.1"
    "Phyllium_giganteum_FJ474312.1"
    "Xylica_oedematosa_FJ474331.1"
    "MN365010.1_Orthomeria_kangi_strain_SB0339"
    "Diapheromera_femorata_FJ474276.1"
    "Eurycantha_calcarata_FJ474282.1"
    "Sipyloidea_sipylus_FJ474324.1"
    "Heteropteryx_dilatata_FJ474291.1"
    "Extatosoma_tiaratum_FJ474284.1"
    "Achrioptera_fallax_KP300914.1"
    "Medauroidea_extradentata_KT426637.1"
    "Embia_tyrrhenica_JQ907057.1"
    "Aposthonia_ceylonica_KC014542.1"
)

# Clear the output file if it already exists
> "$output_file"

# Loop through each accession number and download the corresponding FASTA sequence
for entry in "${accession_names[@]}"; do
    # Extract accession number and species
    accession="${entry##*_}"
    genus_species="${entry%_*}"
    
    # Construct the URL
    url="https://www.ncbi.nlm.nih.gov/sviewer/viewer.fcgi?id=${accession}&db=nuccore&report=fasta"
    
    # Download the sequence, filter out empty lines, and modify the header
    wget -qO- "$url" | sed '/^\s*$/d' | sed "s/^>.*/>${genus_species}/" >> "$output_file"
done

echo "All sequences have been downloaded and saved to $output_file."
