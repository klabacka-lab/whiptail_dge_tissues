#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G   # memory per CPU core
#SBATCH -J "sort_parentage"   # job name

set -euo pipefail


module load miniforge3
mamba activate dge_environment

WORKDIR="$1"

#find eagle-rc tool
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EAGLE_RC="$PROJECT_ROOT/tools/eagle/eagle-rc"

cd "$WORKDIR/mapped_reads"

mkdir -p "$WORKDIR/mapped_reads/classified"

mkdir -p "$WORKDIR/mapped_reads/classified/Marm"
mkdir -p "$WORKDIR/mapped_reads/classified/Sept"

#build sample list
mapfile -t SAMPLES < <(ls *_Marm_combined.sorted.bam | sed -E 's/_Marm_combined\.sorted\.bam$//' | sort -u)

sample_name="${SAMPLES[$SLURM_ARRAY_TASK_ID]}"

"$EAGLE_RC" --ngi \
    --splice \
    -o "$WORKDIR/mapped_reads/classified/${sample_name}_classified" \
    --ref1="$WORKDIR/references/AspMarm/AspMarm.fasta" \
    --ref2="$WORKDIR/references/AspSept/AspSept.fasta" \
    --bam1="${sample_name}_Marm_combined.sorted.bam" \
    --bam2="${sample_name}_Sept_combined.sorted.bam" \
    > "$WORKDIR/mapped_reads/classified/${sample_name}_classified.1vs2.list"

# Split the outputs into per-genome folders:
# "1.*" files come from --bam1 (Marm), "2.*" files come from --bam2 (Sept)
mv "$WORKDIR/mapped_reads/classified/${sample_name}_classified1."*.bam \
   "$WORKDIR/mapped_reads/classified/Marm/"

mv "$WORKDIR/mapped_reads/classified/${sample_name}_classified2."*.bam \
   "$WORKDIR/mapped_reads/classified/Sept/"

echo "EAGLE-RC classification complete for $sample_name"