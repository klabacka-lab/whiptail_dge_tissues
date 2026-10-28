#!/bin/bash

#SBATCH --account=utu
#SBATCH --partition=lonepeak
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=19:00:00
#SBATCH -o out.splicefiles-%j.txt-%N
#SBATCH -e err.splicefiles-%j.txt-%N

# Author: Baylee Christensen
# Date: 09/12/2024
# Description: This script splices the bed file with the merged&filtered vcf file, creating two output files: mito_gene_matches.vcf and no_mito_matches.vcf. The mito_gene_matches.vcf will have a match between the bed file and the vcf and therefore will give us the mito gene associated with the variant. The other file will have an output where no mito gene will be assigned. The bed file only contains mitochondrial genes.
# Usage for cmd line: nohup bash 03_splice_files.sh 
# Usage for sbatch: sbatch 03_splice_files.sh

VCF_FILE_PATH=/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/filtration/hard_filtration/filtered_output_HFStep5.vcf
BED_FILE_PATH=/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/filtration/MiCFiG.bed
OUTPUT_FILE_PATH=/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/spliced_vcfs

module load bedtools/2.28.0
module load bcftools/1.14

# Splice for bed matches (FULL OUTER JOIN)
bedtools intersect -a $VCF_FILE_PATH -b $BED_FILE_PATH -wa -wb > $OUTPUT_FILE_PATH/mito_gene_matches.vcf
# If no match, create other file. (LEFT JOIN IF NULL)
bedtools intersect -a $VCF_FILE_PATH -b $BED_FILE_PATH -v > $OUTPUT_FILE_PATH/no_mito_gene_matches.vcf

module unload bedtools/2.28.0
module unload bcftools/1.14
