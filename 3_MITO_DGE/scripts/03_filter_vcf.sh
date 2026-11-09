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

# Build a BED of MiCFiG gene regions, labelled with the human MitoCarta gene
# symbol (mito_carta_id=, added by MiCFiG's add_gene_name.sh). This works for
# both references; blast_id= only exists in the AspMarm genome annotation.
# Output: ${BED}.gz (sorted, bgzipped, tabix-indexed; 4th column = gene symbol)
awk -v OFS='\t' '
BEGIN { FS = "\t" }
!/^#/ && NF >= 9 {
    gene = "NA"
    n = split($9, attributes, ";")
    for (i = 1; i <= n; i++) {
        if (attributes[i] ~ /^mito_carta_id=/) {
            gene = attributes[i]
            sub(/^mito_carta_id=/, "", gene)
            gsub(/"/, "", gene)
        }
    }
    print $1, $4-1, $5, gene
}' "$GFF" | sort -k1,1 -k2,2n > "$BED"

# Compress and index the final BED file
bgzip -f "$BED"
tabix -f -p bed "${BED}.gz"


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