#!/bin/bash

#SBATCH --account=utu
#SBATCH --partition=lonepeak
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=39:00:00
#SBATCH -o out.varfilter-%j.txt-%N
#SBATCH -e err.varfilter-%j.txt-%N



# Author: Baylee Christensen
# Date: 09/04/2024
# Description: This script filters the vcf file for quality. Then, it creates a bed file from the gff file. 
# Usage for cmd line: nohup bash 02_filter_merged_vcf.sh
# Usage for sbatch: sbatch 02_filter_merged_vcf.sh


VCF_FILE_PATH="/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/vcf_output/merged_output.vcf"
GFF_FILE_PATH=/uufs/chpc.utah.edu/common/home/u6057891/whiptail_dge_tissues/MiCFiG.gff
OUTPUT_FILE_PATH=/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/filtration

module load bedops/2.4.41
module load htslib/1.18
module load bcftools/1.16
module load vcftools

attr_filtration_gff() {
    local gff_file=$GFF_FILE_PATH
    local bed_file=${OUTPUT_FILE_PATH}/$(basename "${gff_file%.gff}.bed")

    # Use bedops to convert gff to bed
    gff2bed < "$gff_file" > "$bed_file"

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
    }' "$gff_file" > "${bed_file}.temp"

    # Overwrite file with new data
    mv "${bed_file}.temp" "$bed_file"

    # Compress and index the final BED file
    tabix -p bed "${bed_file}"
}

hard_variant_filtration (){
    echo "Input VCF: $1"
    echo "Output prefix: $2"
    echo "Output directory: $3"
    mkdir -p "$3"

    # Step 1: Get rid of low-quality (mean) genotyping:
    vcftools --vcf "$1" --out "$3/${2}_HFStep1" --minGQ 20 --recode --recode-INFO-all
    mv "$3/${2}_HFStep1.recode.vcf" "$3/${2}_HFStep1.vcf"
    echo "Post genotype Quality filtration $2 variants: $(grep -v "^#" "$3/${2}_HFStep1.vcf" | wc -l)" >> "$3/log.txt"

    # Step 2: Get rid of low-depth individuals per site
    vcftools --vcf "$3/${2}_HFStep1.vcf" --out "$3/${2}_HFStep2" --minDP 10 --recode --recode-INFO-all
    mv "$3/${2}_HFStep2.recode.vcf" "$3/${2}_HFStep2.vcf"
    echo "Post depth filtration $2 variants: $(grep -v "^#" "$3/${2}_HFStep2.vcf" | wc -l)" >> "$3/log.txt"

    # Step 3: Get rid of multiallelic SNPs (more than 2 alleles):
    bcftools view -m2 -M2 -v snps "$3/${2}_HFStep2.vcf" > "$3/${2}_HFStep3.vcf"
    echo "Post multiallelic filtration $2 variants: $(grep -v "^#" "$3/${2}_HFStep3.vcf" | wc -l)" >> "$3/log.txt"

    # Step 4: Get rid of low-frequency alleles - singletons:
    vcftools --mac 2 --vcf "$3/${2}_HFStep3.vcf" --recode --recode-INFO-all --out "$3/${2}_HFStep4"
    mv "$3/${2}_HFStep4.recode.vcf" "$3/${2}_HFStep4.vcf"
    echo "Post singleton filtration $2 variants: $(grep -v "^#" "$3/${2}_HFStep4.vcf" | wc -l)" >> "$3/log.txt"

    # Step 5: Remove sites with high missing data
    vcftools --max-missing 0.3 --vcf "$3/${2}_HFStep4.vcf" --recode --recode-INFO-all --out "$3/${2}_HFStep5"
    mv "$3/${2}_HFStep5.recode.vcf" "$3/${2}_HFStep5.vcf"
    echo "Post removal of sites with high missing data: $(grep -v "^#" "$3/${2}_HFStep5.vcf" | wc -l)" >> "$3/log.txt"

    # Finishing: Compress and index data
    bcftools index -f "$3/${2}_HFStep5.vcf"
}

mkdir -p $OUTPUT_FILE_PATH
# Call function
attr_filtration_gff
hard_variant_filtration "$VCF_FILE_PATH" filtered_output ${OUTPUT_FILE_PATH}/hard_filtration

module unload bedops/2.4.41
module unload htslib/1.18
module unload bcftools/1.16
module unload vcftools
