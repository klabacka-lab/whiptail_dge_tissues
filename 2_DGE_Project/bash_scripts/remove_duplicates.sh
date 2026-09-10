#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G   # memory per CPU core
#SBATCH -J "remove_dupes"   # job name
#SBATCH -o logs/remove_dupes.out
#SBATCH -e logs/remove_dupes.err

#set working directory
BAMS="$1"

cd $BAMS

mkdir -p "$BAMS"/nodupes

module load miniforge3
mamba activate dge_environment

mapfile -t BAM_LIST < <(ls "$BAMS"/*.ref.bam)

bam="${BAM_LIST[$SLURM_ARRAY_TASK_ID]}"
sample_name=$(basename "$bam" | cut -d "_" -f "1,2" )

picard MarkDuplicates \
    REMOVE_DUPLICATES=true \
    I="$bam" \
    O="nodupes/${sample_name}.ref.nodupes.bam" \
    M="nodupes/${sample_name}.ref.dup.metrics.txt" 