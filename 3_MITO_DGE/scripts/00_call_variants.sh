#!/bin/bash

#SBATCH --account=utu
#SBATCH --partition=lonepeak
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=19:00:00
#SBATCH -o out.varcalling-%j.txt-%N
#SBATCH -e err.varcalling-%j.txt-%N



# Author: Baylee Christensen
# Date: 09/03/2024
# Description: This script searches for the bam file pattern previously generated, and runs the variant caller between the bam files and the a.marmoratus fasta file
# Usage for cmd line: nohup bash 00_call_variants.sh <path/to/mapped_reads/dir>
# Usage for sbatch: sbatch 00_call_variants.sh <path/to/mapped_reads/dir>


module load bcftools/1.16
# Check if the directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Directory to search 
DIRECTORY="$1"

# Reference file
REFERENCE="a_marmoratus_AspMarm2.0.fasta"

# Output directory for VCF files
OUTPUT_DIR="/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/vcf_output"
mkdir -p "$OUTPUT_DIR"
echo "NOTE: Your output files will be located in $OUTPUT_DIR, NOT your current wd"

# List files in the directory, grep for the pattern, and loop through each matching BAM file
# Searches for pattern "Am_??.bam"

for BAM_FILE in $(ls "$DIRECTORY" | grep -E '^Am_[0-9]{2}\_removed_duplicates.bam$'); do
  # Define output VCF filename based on BAM filename
  VCF_FILE="$OUTPUT_DIR/${BAM_FILE%.bam}.vcf"

  # Run bcftools to call variants
  bcftools mpileup -f "$REFERENCE" "$DIRECTORY/$BAM_FILE" --annotate FORMAT/AD,FORMAT/DP,FORMAT/SP | \
  bcftools call -mv -Ov -o "$VCF_FILE"

  echo "Variants called for $BAM_FILE and saved to $VCF_FILE."
done

module unload bcftools/1.16
