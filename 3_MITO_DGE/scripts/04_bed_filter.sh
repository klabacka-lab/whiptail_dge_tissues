#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G   # memory per CPU core
#SBATCH -J "bed_filter"   # job name
#SBATCH -o logs/bed_filter.out
#SBATCH -e logs/bed_filter.err

module load miniforge3
mamba activate dge_environment

WORKDIR=$1
BED=$WORKDIR/protein_sites.bed
VCF=$WORKDIR/filtered_HFStep5.vcf.gz

bedtools intersect -a $VCF -b $BED -u -header > $WORKDIR/protein_sites.vcf

bgzip $WORKDIR/protein_sites.vcf

tabix -p vcf $WORKDIR/protein_sites.vcf.gz