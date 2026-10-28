#!/bin/bash

#SBATCH --account=utu
#SBATCH --partition=lonepeak
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=29:00:00
#SBATCH -o out.matrixify-%j.txt-%N
#SBATCH -e err.matrixify-%j.txt-%N

# Author: Baylee Christensen
# Date: 09/13/2024
# Description: This function creates a data table for the variants that have a
# gene match and no gene match. The headers are:
# "SampleID","Chromosome","Position","Gene","RefAD","AltAD","DeltaAD","GT.PL.DP.SP.AD","FieldTag","Tissue","GeneType"
# Depending on if your file has matches for genes or not, you will choose the
# format type of 'match' or 'no_match'

# Usage for filetype with gene matches in sbatch:
# sbatch 04_matrixify.sh -v /scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/spliced_vcfs/rd_mito_gene_matches.vcf -o /scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/matrix/rd_mito_variants.csv -f gene_match
# Usage for filetype with gene matches in sbatch:
# sbatch 04_matrixify.sh -v /scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/spliced_vcfs/rd_no_mito_gene_matches.vcf -o /scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/matrix/rd_no_mito_variants.csv -f no_match

PY_SCRIPT_PATH=/uufs/chpc.utah.edu/common/home/u6057891/whiptail_dge_tissues
R_SCRIPT_PATH=/uufs/chpc.utah.edu/common/home/u6057891/whiptail_dge_tissues

# Argument parser
while getopts v:o:f: flag
do
    case "${flag}" in
        v) VCF_BED_FILE_PATH=${OPTARG};;
        o) OUTPUT_FILE_PATH=${OPTARG};;
	f) FORMAT_TYPE=${OPTARG};;
    esac
done

# Calls python script to output the combined matrix
python3 ${PY_SCRIPT_PATH}/04_p_matrixify.py -i "$VCF_BED_FILE_PATH" -o "$OUTPUT_FILE_PATH" -f "$FORMAT_TYPE"


# Ensure Python script ran successfully
if [[ $? -ne 0 ]]; then
    echo "Python script failed. Exiting."
    exit 1
fi

# Calls R script with the output file from the Python script
Rscript "${R_SCRIPT_PATH}/04_r_matrixify.R" "$OUTPUT_FILE_PATH"

if [[ $? -ne 0 ]]; then
    echo "R script failed. Exiting."
    exit 1
fi



echo "Complete"
