#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G   # memory per CPU core
#SBATCH -J "count_reads"   # job name
#SBATCH -o logs/count_reads.out
#SBATCH -e logs/count_reads.err


module load miniforge3
mamba activate dge_environment

# Define file paths
WORKDIR="$1"

marm_gtf="$WORKDIR/references/AspMarm/AspMarm.gtf"
sept_gtf="$WORKDIR/references/AspSept/AspSept.gtf"

marm_dir="$WORKDIR/haplotype/Marm/nodupes"
sept_dir="$WORKDIR/haplotype/Sept/nodupes"

mkdir -p "$WORKDIR/analysis"

#######################################################
# Creating Counts from Marm-origin #
#######################################################

featureCounts \
    -T 8 \
    -a "$marm_gtf" \
    -o "$WORKDIR/analysis/marm_counts.txt" \
    "$marm_dir"/*.bam

#######################################################
# Creating Counts from Sept-origin #
#######################################################

featureCounts \
    -T 8 \
    -a "$sept_gtf" \
    -o "$WORKDIR/analysis/sept_counts.txt" \
    "$sept_dir"/*.bam