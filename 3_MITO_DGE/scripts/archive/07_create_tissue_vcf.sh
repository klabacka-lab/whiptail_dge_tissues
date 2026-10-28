#!/bin/bash

# Author: Baylee Christensen
# Date: 10/31/2024
# Description: This process combines the vcfs from the individuals based on tissue type
# Usage: sbatch 07_create_tissue_vcf.sh /scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/vcf_output

#SBATCH --account=utu
#SBATCH --partition=lonepeak
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=45:00:00
#SBATCH -o out.vartissuemerging-%j.txt-%N
#SBATCH -e err.vartissuemerging-%j.txt-%N

# Heart: 1,4,7,10,13,25
# Liver: 2,5,8,11,14,26
# Skeletal Muscle: 3,6,9,12,15,27

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

# Define tissue type groups based on file numbers
declare -A TISSUE_GROUPS
TISSUE_GROUPS["Heart"]="1 4 7 10 13 25"
TISSUE_GROUPS["Liver"]="2 5 8 11 14 26"
TISSUE_GROUPS["Skeletal_Muscle"]="3 6 9 12 15 27"

# Loop through each tissue type and merge relevant files
for TISSUE in "${!TISSUE_GROUPS[@]}"; do
    VCF_FILES=""
    
    for NUM in ${TISSUE_GROUPS[$TISSUE]}; do
        VCF_FILE="Am_$(printf "%02d" "$NUM")_removed_duplicates.vcf"
        FULL_PATH="$DIRECTORY/$VCF_FILE"
        
        if [ -f "$FULL_PATH" ]; then
            # Compress and index the VCF file
            bgzip -c "$FULL_PATH" > "$FULL_PATH.gz"
            bcftools index "$FULL_PATH.gz"
            VCF_FILES="$VCF_FILES $FULL_PATH.gz"
        else
            echo "Warning: $VCF_FILE not found in $DIRECTORY"
        fi
    done

    # Merge the VCF files for the current tissue type
    if [ -n "$VCF_FILES" ]; then
        OUTPUT_FILE="$OUTPUT_DIR/${TISSUE}_combined.vcf"
        bcftools merge $VCF_FILES -o "$OUTPUT_FILE"
        echo "$TISSUE VCF files have been merged and saved to $OUTPUT_FILE"
    else
        echo "No VCF files found for $TISSUE"
    fi
done
