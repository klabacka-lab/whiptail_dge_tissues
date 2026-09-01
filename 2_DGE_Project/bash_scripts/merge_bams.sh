#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=16
#SBATCH --mem=16G   # memory per CPU core
#SBATCH -J "merge_bams"   # job name

set -euo pipefail

WORKDIR="$1"

module load miniforge3
mamba activate dge_environment

cd "$WORKDIR/mapped_reads"

#################################################
# Merge the merge & unmerge into ultimate merge #
#################################################

mapfile -t SAMPLES < <(ls *_Marm_m*.bam | sed -E 's/_Marm_m.*\.bam$//' | sort -u)

sample_name="${SAMPLES[$SLURM_ARRAY_TASK_ID]}"

samtools merge -f "${sample_name}_Marm_combined.bam" \
	"${sample_name}_Marm_m"*.bam "${sample_name}_Marm_um"*.bam

samtools sort -@ 16 -o "${sample_name}_Marm_combined.sorted.bam" "${sample_name}_Marm_combined.bam"
samtools index "${sample_name}_Marm_combined.sorted.bam"

samtools merge -f "${sample_name}_Sept_combined.bam" \
	"${sample_name}_Sept_m"*.bam "${sample_name}_Sept_um"*.bam

samtools sort -@ 16 -o "${sample_name}_Sept_combined.sorted.bam" "${sample_name}_Sept_combined.bam"
samtools index "${sample_name}_Sept_combined.sorted.bam"

echo "Merging bams for $sample_name complete"