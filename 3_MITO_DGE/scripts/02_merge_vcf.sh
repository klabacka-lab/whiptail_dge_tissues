#!/bin/bash

#SBATCH --time=48:00:00   # walltime
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G   # memory per CPU core
#SBATCH -J "varmerging"   # job name
#SBATCH -o logs/varmerging.out
#SBATCH -e logs/varmerging.err



# Author: Baylee Christensen
# Date: 09/04/2024
# Description: This script merges all vcf files from previous output (because we have multiple lizard vcf files) into one

module load miniforge3
mamba activate bcftools

# Directory to search 
WORKDIR="$1" 

#create list of existing vcf files
ls "$WORKDIR"/Am_*.vcf.gz > vcf_list.txt

bcftools merge \
  --file-list vcf_list.txt \
  --threads 8 \
  -Oz -o "$WORKDIR/merged_output.vcf.gz"

#index new merged vcf
bcftools index -t "$WORKDIR/merged_output.vcf.gz"

rm vcf_list.txt