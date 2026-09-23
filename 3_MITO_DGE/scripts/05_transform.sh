#!/bin/bash


# Small process, OK to run from head node 
# Author: Baylee Christensen
# Date: 10/01/2024
# Description: This takes in two csv files from previous output, and combined them into one while preserving the header from the first file. It then compressed the combined input into a .gz file, named combined_variants.csv.gz 
# Output: In {OUTPUT_DIR}/combined_variants.csv.gz
# Usage for cmd line:


# Combine two csvs from previous output
MATCHES=/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/matrix/rd_mito_variants_updated.csv
NO_MATCHES=/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/matrix/rd_no_mito_variants_updated.csv
OUTPUT_DIR=/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/matrix

{ head -n 1 ${MATCHES} && tail -n +2 -q ${MATCHES} ${NO_MATCHES}; } > $OUTPUT_DIR/combined_variants.csv && gzip $OUTPUT_DIR/combined_variants.csv

