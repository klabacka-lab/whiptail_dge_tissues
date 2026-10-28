#!/bin/bash

#SBATCH --time=48:00:00   # walltime
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G   # memory per CPU core
#SBATCH -J "filtering"   # job name
#SBATCH -o logs/filtering.out
#SBATCH -e logs/filtering.err



# Author: Baylee Christensen
# Date: 09/04/2024
# Description: This script filters the vcf file for quality. Then, it creates a bed file from the gff file. 
# Usage for cmd line: nohup bash 02_filter_merged_vcf.sh
# Usage for sbatch: sbatch 02_filter_merged_vcf.sh


VCF=$1
GFF=$2
BED=$3
OUTPUT=$4

module load miniforge3
mamba activate dge_environment

# Use bedops to convert gff to bed
gff2bed < "$GFF" > "$BED"

# Retain gene attribute from the gff and add them to the bed file
# 1. Split the 9th column by semicolon to extract attributes
# 2. Extract pattern between '|' and '_'
# 3. Add the extracted blast_id to the BED file

awk -v OFS='\t' '
BEGIN { FS = "\t" }
{
    split($9, attributes, ";");  
    for (i in attributes) {
        if (attributes[i] ~ /blast_id=/) {
            match(attributes[i], /sp\|[^|]+\|([^_]+)_/, id);  
            blast_id = id[1];  
        }
    }
    print $1, $4, $5, blast_id;  # Add the extracted blast_id to the BED file
}' "$GFF" > "${BED}.temp"

# Overwrite file with new data
mv "${BED}.temp" "$BED"

# Compress and index the final BED file
tabix -p bed "${BED}"


# Step 1: Get rid of low-quality (mean) genotyping:
vcftools --gzvcf "$VCF" --out "$OUTPUT/filtered_HFStep1" --minGQ 20 --recode --recode-INFO-all
mv "$OUTPUT/filtered_HFStep1.recode.vcf" "$OUTPUT/filtered_HFStep1.vcf"

# Step 2: Get rid of low-depth individuals per site
vcftools --vcf "$OUTPUT/filtered_HFStep1.vcf" --out "$OUTPUT/filtered_HFStep2" --minDP 10 --recode --recode-INFO-all
mv "$OUTPUT/filtered_HFStep2.recode.vcf" "$OUTPUT/filtered_HFStep2.vcf"

# Step 3: Get rid of multiallelic SNPs (more than 2 alleles):
mamba activate bcftools
bcftools view -m2 -M2 -v snps "$OUTPUT/filtered_HFStep2.vcf" > "$OUTPUT/filtered_HFStep3.vcf"

# Step 4: Get rid of low-frequency alleles - singletons:
mamba activate dge_environment
vcftools --mac 2 --vcf "$OUTPUT/filtered_HFStep3.vcf" --recode --recode-INFO-all --out "$OUTPUT/filtered_HFStep4"
mv "$OUTPUT/filtered_HFStep4.recode.vcf" "$OUTPUT/filtered_HFStep4.vcf"

# Step 5: Remove sites with high missing data
vcftools --max-missing 0.3 --vcf "$OUTPUT/filtered_HFStep4.vcf" --recode --recode-INFO-all --out "$OUTPUT/filtered_HFStep5"
mv "$OUTPUT/filtered_HFStep5.recode.vcf" "$OUTPUT/filtered_HFStep5.vcf"

# Finishing: Compress and index data
mamba activate bcftools
bgzip -f $OUTPUT/filtered_HFStep5.vcf
bcftools index -f "$OUTPUT/filtered_HFStep5.vcf.gz"