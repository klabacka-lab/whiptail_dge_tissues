#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G   # memory per CPU core
#SBATCH -J "categorize_vcf"   # job name
#SBATCH -o logs/categorize_vcf.out
#SBATCH -e logs/categorize_vcf.err

#splits up the vcf by tissue types and county
module load miniforge3
mamba activate dge_environment

WORKDIR=$1

VCF=$WORKDIR/protein_sites.vcf.gz

#skeletal muscle only
vcftools --gzvcf $VCF --keep SM_samples.txt \
    --recode --recode-INFO-all --out $WORKDIR/SM_protein

mv $WORKDIR/SM_protein.recode.vcf $WORKDIR/SM_protein.vcf
bgzip -f $WORKDIR/SM_protein.vcf
tabix -p vcf "$WORKDIR/SM_protein.vcf.gz"

#Liver only
vcftools --gzvcf $VCF --keep L_samples.txt \
    --recode --recode-INFO-all --out $WORKDIR/L_protein

mv $WORKDIR/L_protein.recode.vcf $WORKDIR/L_protein.vcf
bgzip -f $WORKDIR/L_protein.vcf
tabix -p vcf "$WORKDIR/L_protein.vcf.gz"

#Heart only
vcftools --gzvcf $VCF --keep H_samples.txt \
    --recode --recode-INFO-all --out $WORKDIR/H_protein

mv $WORKDIR/H_protein.recode.vcf $WORKDIR/H_protein.vcf
bgzip -f $WORKDIR/H_protein.vcf
tabix -p vcf "$WORKDIR/H_protein.vcf.gz"

#Culberson only
vcftools --gzvcf $VCF --keep culberson_samples.txt \
    --recode --recode-INFO-all --out $WORKDIR/culberson_protein

mv $WORKDIR/culberson_protein.recode.vcf $WORKDIR/culberson_protein.vcf
bgzip -f $WORKDIR/culberson_protein.vcf
tabix -p vcf "$WORKDIR/culberson_protein.vcf.gz"

#SantaFe only
vcftools --gzvcf $VCF --keep SantaFe_samples.txt \
    --recode --recode-INFO-all --out $WORKDIR/SantaFe_protein

mv $WORKDIR/SantaFe_protein.recode.vcf $WORKDIR/SantaFe_protein.vcf
bgzip -f $WORKDIR/SantaFe_protein.vcf
tabix -p vcf "$WORKDIR/SantaFe_protein.vcf.gz"

#brewster only
vcftools --gzvcf $VCF --keep brewster_samples.txt \
    --recode --recode-INFO-all --out $WORKDIR/brewster_protein

mv $WORKDIR/brewster_protein.recode.vcf $WORKDIR/brewster_protein.vcf
bgzip -f $WORKDIR/brewster_protein.vcf
tabix -p vcf "$WORKDIR/brewster_protein.vcf.gz"