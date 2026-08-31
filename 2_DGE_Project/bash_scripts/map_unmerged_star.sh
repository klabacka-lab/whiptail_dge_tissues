#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G   # memory per CPU core
#SBATCH -J "map_rna_tesselatus"   # job name
# This file maps the reads to the reference genome

# map unmerged clean reads
STAR --genomeDir "$WORKDIR/references/AspMarm" \
  --runThreadN 8 \
  --readFilesIn  "$WORKDIR/cleaned_reads/unmerged_reads/${sample_name}_unmerged1.fastq" \
  "$WORKDIR/cleaned_reads/unmerged_reads/${sample_name}_unmerged2.fastq" \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix "$WORKDIR/mapped_reads/${sample_name}_Marm_um"

STAR --genomeDir "$WORKDIR/references/AspSept" \
  --runThreadN 8 \
  --readFilesIn  "$WORKDIR/cleaned_reads/unmerged_reads/${sample_name}_unmerged1.fastq" \
  "$WORKDIR/cleaned_reads/unmerged_reads/${sample_name}_unmerged2.fastq" \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix "$WORKDIR/mapped_reads/${sample_name}_Sept_um"