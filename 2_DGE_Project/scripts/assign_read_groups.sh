#!/bin/bash

#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH -J "add_read_groups"
#SBATCH -o logs/add_read_groups.out
#SBATCH -e logs/add_read_groups.err

BAMS="$1"

cd "$BAMS"

mkdir -p "$BAMS"/rg_added

module load miniforge3
mamba activate dge_environment

mapfile -t BAM_LIST < <(ls "$BAMS"/*.ref.bam)

bam="${BAM_LIST[$SLURM_ARRAY_TASK_ID]}"

sample_name=$(basename "$bam" | cut -d "_" -f "1,2")

rgpu=$(samtools view "$bam" | head -1 | cut -f1 | awk -F: '{print $3"."$4}')


picard AddOrReplaceReadGroups \
    -I "$bam" \
    -O "rg_added/${sample_name}.ref.rg.bam" \
    -RGID "$sample_name" \
    -RGLB lib1 \
    -RGPL illumina \
    -RGPU "$rgpu" \
    -RGSM "$sample_name"