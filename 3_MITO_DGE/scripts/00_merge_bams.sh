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

   samtools index "mito_dge/${s}_marm_merged.bam"
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
   
   samtools index "mito_dge/${s}_sept_merged.bam"
done