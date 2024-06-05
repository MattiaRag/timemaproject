import os
import subprocess
from pathlib import Path

# Base directories
base_dir = "1a"
nu_dir = os.path.join(base_dir, "orthogroupsdisco_nu")
aa_dir = os.path.join(base_dir, "orthogroupsdisco_aa")
maff = os.path.join(base_dir, "orthogroupsdisco_aa/Maffted")
tr_aa = os.path.join(base_dir, "orthogroupsdisco_aa/Trimmed_aa")
tr_nu = os.path.join(base_dir, "orthogroupsdisco_nu/Trimmed_nu")
iqin_aa = os.path.join(base_dir, "orthogroupsdisco_aa/Iqtreeinput_aa")
iqin_nu = os.path.join(base_dir, "orthogroupsdisco_nu/Iqtreeinput_nu")
ls_aa = os.path.join(base_dir, "orthogroupsdisco_aa/lessthan5headers_aa")
ls_nu = os.path.join(base_dir, "orthogroupsdisco_nu/lessthan5headers_nu")
iqout_aa = os.path.join(base_dir, "orthogroupsdisco_aa/Iqtreeoutput_aa")
iqout_nu = os.path.join(base_dir, "orthogroupsdisco_nu/Iqtreeoutput_nu")

# Create directories if they don't exist
directories = [nu_dir, aa_dir, maff, tr_aa, tr_nu, iqin_aa, iqin_nu, ls_aa, ls_nu, iqout_aa, iqout_nu]
for directory in directories:
    os.makedirs(directory, exist_ok=True)

def run_command(command):
    print(f"Running command: {command}")
    subprocess.run(command, shell=True, check=True)

def rename_headers(input_file, output_file):
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if line.startswith('>'):
                header = line.split('_')[0] + '\n'
                outfile.write(header)
            else:
                outfile.write(line)

# Loop through all .fa files in the amino acid orthogroups directory
for fasta_file in Path(aa_dir).glob("*.fa"):
    base_name = fasta_file.stem

    # Perform sequence alignment using MAFFT with automatic settings
    mafft_output = os.path.join(maff, f"{base_name}.mafft.fa")
    run_command(f"mafft --auto {fasta_file} > {mafft_output}")

    # Perform trimming of the alignment with trimAl
    tr_aa_output = os.path.join(tr_aa, f"{base_name}.trimmed.fa")
    run_command(f"trimal -in {mafft_output} -resoverlap 0.5 -seqoverlap 50 -gappyout > {tr_aa_output}")

    tr_nu_output = os.path.join(tr_nu, f"{base_name}.trimmed.fa")
    nu_fasta_file = os.path.join(nu_dir, f"{base_name}.fa")
    run_command(f"trimal -in {mafft_output} -resoverlap 0.5 -seqoverlap 50 -gappyout -ignorestopcodon -backtrans {nu_fasta_file} > {tr_nu_output}")

    # Process amino acid trimmed file
    if os.path.getsize(tr_aa_output) > 0:
        iqin_aa_input = os.path.join(iqin_aa, f"{base_name}.input.fa")
        rename_headers(tr_aa_output, iqin_aa_input)

        # Count headers in the input file for IQ-TREE
        with open(iqin_aa_input, 'r') as f:
            header_count_aa = sum(1 for line in f if line.startswith('>'))

        # Check if the input file has at least 5 headers
        if header_count_aa >= 5:
            iqtree_output_prefix = os.path.join(iqout_aa, f"loci_{base_name}")
            run_command(f"iqtree2 -s {iqin_aa_input} --prefix {iqtree_output_prefix} -T AUTO")
        else:
            os.rename(iqin_aa_input, os.path.join(ls_aa, f"{base_name}.input.fa"))
            print(f"{base_name} has less than 5 headers and was moved to lessthan5headers folder.")
    else:
        print(f"{tr_aa_output} is empty.")

    # Process nucleotide trimmed file
    if os.path.getsize(tr_nu_output) > 0:
        iqin_nu_input = os.path.join(iqin_nu, f"{base_name}.input.fa")
        rename_headers(tr_nu_output, iqin_nu_input)

        # Count headers in the input file for IQ-TREE
        with open(iqin_nu_input, 'r') as f:
            header_count_nu = sum(1 for line in f if line.startswith('>'))

        # Check if the input file has at least 5 headers
        if header_count_nu >= 5:
            iqtree_output_prefix = os.path.join(iqout_nu, f"loci_{base_name}")
            run_command(f"iqtree2 -s {iqin_nu_input} --prefix {iqtree_output_prefix} -T AUTO")
        else:
            os.rename(iqin_nu_input, os.path.join(ls_nu, f"{base_name}.input.fa"))
            print(f"{base_name} has less than 5 headers and was moved to lessthan5headers folder.")
    else:
        print(f"{tr_nu_output} is empty.")

print("Processing complete.")
