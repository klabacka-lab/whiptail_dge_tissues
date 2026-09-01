#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G   # memory per CPU core
#SBATCH -J "map_rna_tesselatus_unmerged"   # job name
#SBATCH -o logs/map_unmerged.out
#SBATCH -e logs/map_unmerged.err
# This file maps the reads to the reference genome
# map unmerged clean reads

set -euo pipefail

WORKDIR="$1"

module load miniforge3
mamba activate dge_environment

echo "Aligning unmerged reads against references with STAR"
echo ""

mapfile -t UNMERGED1_READS < <(ls "$WORKDIR/cleaned_reads/unmerged_reads"/*_unmerged1.fastq)

unmerged1="${UNMERGED1_READS[$SLURM_ARRAY_TASK_ID]}"
sample_name=$(basename "$unmerged1" | cut -d "_" -f "1,2")

unmerged2="$WORKDIR/cleaned_reads/unmerged_reads/${sample_name}_unmerged2.fastq"

STAR --genomeDir "$WORKDIR/references/AspMarm" \
  --runThreadN 16 \
  --readFilesIn  "$unmerged1" "$unmerged2" \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix "$WORKDIR/mapped_reads/${sample_name}_Marm_um"

STAR --genomeDir "$WORKDIR/references/AspSept" \
  --runThreadN 16 \
  --readFilesIn  "$unmerged1" "$unmerged2" \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix "$WORKDIR/mapped_reads/${sample_name}_Sept_um"