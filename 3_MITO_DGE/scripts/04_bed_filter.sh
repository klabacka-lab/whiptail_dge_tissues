#!/bin/bash

#SBATCH --time=02:00:00   # walltime
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH -J "bed_filter"   # job name
#SBATCH -o logs/bed_filter.out
#SBATCH -e logs/bed_filter.err

# Keeps only variants inside MiCFiG gene regions and records the overlapping
# gene (human MitoCarta symbol) in INFO/GENE so it travels through the
# per-tissue/county splits in 05_categorize_vcf.sh.
# Usage: sbatch 04_bed_filter.sh <filtered_dir>

set -eo pipefail

module load miniforge3
mamba activate dge_environment

WORKDIR=$1
BED=$WORKDIR/protein_sites.bed.gz
VCF=$WORKDIR/filtered_HFStep5.vcf.gz

bedtools intersect -a $VCF -b $BED -u -header | bgzip -c > $WORKDIR/protein_sites.tmp.vcf.gz

mamba activate bcftools
echo '##INFO=<ID=GENE,Number=1,Type=String,Description="Human MitoCarta gene symbol of the overlapping MiCFiG gene region">' > $WORKDIR/gene_header.txt
bcftools annotate -a $BED -c CHROM,FROM,TO,INFO/GENE -h $WORKDIR/gene_header.txt \
    -Oz -o $WORKDIR/protein_sites.vcf.gz $WORKDIR/protein_sites.tmp.vcf.gz
rm -f $WORKDIR/protein_sites.tmp.vcf.gz $WORKDIR/gene_header.txt

bcftools index -f -t $WORKDIR/protein_sites.vcf.gz

echo "protein_sites.vcf.gz records: $(bcftools view -H $WORKDIR/protein_sites.vcf.gz | wc -l)"
