#!/bin/bash

#SBATCH --account=utu
#SBATCH --partition=lonepeak
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=45:00:00
#SBATCH -o out.varmerging-%j.txt-%N
#SBATCH -e err.varmerging-%j.txt-%N


# Author: Baylee Christensen
# Date: 09/04/2024
# Description: This script merges all vcf files from previous output (because we have multiple lizard vcf files) into one
# Usage for command line: bash 01_merge_vcf.sh /scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/vcf_output 
# Usage for sbatch: sbatch 01_merge_vcf.sh /scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/vcf_output

module load bcftools/1.16
module load htslib/1.16

# Check if the directory is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

# Directory to search 
DIRECTORY="$1" 

# Output directory for VCF files
OUTPUT_DIR="/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/vcf_output"
echo "Initiating merge..."
echo "NOTE: Your output files will be located in $OUTPUT_DIR, NOT your current wd"
echo ""

# Create a variable to hold the full paths to the VCF files for merging
VCF_FILES=""


# Search all files matching the Am pattern, and loop to index them
# Pattern: "Am_??.vcf"
for VCF_FILE in $(ls "$DIRECTORY" | grep -E '^Am_[0-9]{2}\.vcf$'); do
    # Full path to the VCF file
    FULL_PATH="$DIRECTORY/$VCF_FILE"

    # Compress the VCF file using bgzip
    bgzip -c "$FULL_PATH" > "$FULL_PATH.gz"
    
    # Index the VCF file
    bcftools index "$FULL_PATH.gz"
    
    # Add the full path of the indexed VCF file to the list
    VCF_FILES="$VCF_FILES $FULL_PATH.gz"
done

# Merge the indexed VCF files
bcftools merge $VCF_FILES -o "$OUTPUT_DIR/merged_output.vcf"

echo "VCF files have been merged and saved to $OUTPUT_DIR/merged_output.vcf"




module unload bcftools/1.16
module unload htslib/1.16
