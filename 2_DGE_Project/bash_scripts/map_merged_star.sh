#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G   # memory per CPU core
#SBATCH -J "map_rna_tesselatus"   # job name
#SBATCH -o logs/map_merged.out
#SBATCH -e logs/map_merged.err
# This file maps the reads to the reference genome

set -euo pipefail

#set working directory
WORKDIR="$1"

module load miniforge3
mamba activate dge_environment

#############
# map reads #
#############

# This creats .bam files for the merged reads, .sam files are not created. 
# Our original samples were titled "Am_01_merged..."

echo "Aligning Merged Reads against References with STAR"
echo ""

mapfile -t MERGED_READS < <(ls "$WORKDIR/cleaned_reads/merged_reads"/*.fastq.gz)

merged_read="${MERGED_READS[$SLURM_ARRAY_TASK_ID]}"
sample_name=$(basename "$merged_read" | cut -d "_" -f "1,2" )

# map merged clean reads
STAR --genomeDir "$WORKDIR/references/AspMarm" \
  --runThreadN 16 \
  --readFilesIn  "$merged_read" \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix "$WORKDIR/mapped_reads/${sample_name}_Marm_m"

STAR --genomeDir "$WORKDIR/references/AspSept" \
  --runThreadN 16 \
  --readFilesIn  "$merged_read" \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix "$WORKDIR/mapped_reads/${sample_name}_Sept_m"


echo "Alignment completed successfully for $merged_read"