#!/bin/bash

#SBATCH --time=20:00:00   # walltime
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G   # memory per CPU core
#SBATCH -J "mito_dge"   # job name
#SBATCH -o logs/mito_dge.out
#SBATCH -e logs/mito_dge.err
#SBATCH --mail-user=vanwper@byu.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#activate environment
module load miniforge3
mamba activate samtools_env

WORKDIR=$1

mkdir -p $WORKDIR/haplotype/Marm/mito_dge
mkdir -p $WORKDIR/haplotype/Sept/mito_dge

#Give read groups and Merge Marm bams
cd $WORKDIR/haplotype/Marm

mapfile -t samples < <(printf '%s\n' *_classified1.*.bam | sed 's/_classified1\..*//' | sort -u)

for s in "${samples[@]}"; do
   samtools addreplacerg -r \
      "@RG\tID:${s}_ref\tSM:${s}" \
      -o mito_dge/"${s}_ref.bam" \
      "${s}_classified1.ref.bam"

   samtools addreplacerg -r \
      "@RG\tID:${s}_alt\tSM:${s}" \
      -o mito_dge/"${s}_alt.bam" \
      "${s}_classified1.alt.bam"

   samtools merge \
      -o "mito_dge/${s}_marm_merged.bam" \
      "mito_dge/${s}_ref.bam" \
      "mito_dge/${s}_alt.bam"

   samtools sort -n -@ 8 -o "mito_dge/${s}_namesorted.bam" "mito_dge/${s}_marm_merged.bam"
   samtools fixmate -m -@ 8 "mito_dge/${s}_namesorted.bam" "mito_dge/${s}_fixmate.bam"
   samtools sort -@ 8 -o "mito_dge/${s}_coordsorted.bam" "mito_dge/${s}_fixmate.bam"
   samtools markdup -s -@ 8 "mito_dge/${s}_coordsorted.bam" "mito_dge/${s}_marm_dedup.bam" \
      2> "mito_dge/${s}_marm_markdup_stats.txt"

   samtools index "mito_dge/${s}_marm_dedup.bam"

   rm -f "mito_dge/${s}_ref.bam" "mito_dge/${s}_alt.bam" \
      "mito_dge/${s}_marm_merged.bam" "mito_dge/${s}_namesorted.bam" \
      "mito_dge/${s}_fixmate.bam" "mito_dge/${s}_coordsorted.bam"
done

#Give read groups and Merge Sept bams
cd $WORKDIR/haplotype/Sept

mapfile -t samples < <(printf '%s\n' *_classified2.*.bam | sed 's/_classified2\..*//' | sort -u)

for s in "${samples[@]}"; do
   samtools addreplacerg -r \
      "@RG\tID:${s}_ref\tSM:${s}" \
      -o mito_dge/"${s}_ref.bam" \
      "${s}_classified2.ref.bam"

   samtools addreplacerg -r \
      "@RG\tID:${s}_alt\tSM:${s}" \
      -o mito_dge/"${s}_alt.bam" \
      "${s}_classified2.alt.bam"

   samtools merge \
      -o "mito_dge/${s}_sept_merged.bam" \
      "mito_dge/${s}_ref.bam" \
      "mito_dge/${s}_alt.bam"
   
   samtools sort -n -@ 8 -o "mito_dge/${s}_namesorted.bam" "mito_dge/${s}_sept_merged.bam"
   samtools fixmate -m -@ 8 "mito_dge/${s}_namesorted.bam" "mito_dge/${s}_fixmate.bam"
   samtools sort -@ 8 -o "mito_dge/${s}_coordsorted.bam" "mito_dge/${s}_fixmate.bam"
   samtools markdup -s -@ 8 "mito_dge/${s}_coordsorted.bam" "mito_dge/${s}_sept_dedup.bam" \
      2> "mito_dge/${s}_sept_markdup_stats.txt"

   samtools index "mito_dge/${s}_sept_dedup.bam"

   rm -f "mito_dge/${s}_ref.bam" "mito_dge/${s}_alt.bam" \
         "mito_dge/${s}_sept_merged.bam" "mito_dge/${s}_namesorted.bam" \
         "mito_dge/${s}_fixmate.bam" "mito_dge/${s}_coordsorted.bam"
done