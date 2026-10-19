#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=16
#SBATCH --mem=120G   # memory per CPU core
#SBATCH -J "call_variants_marm"   # job name
#SBATCH -o logs/call_variants_marm_%a.out
#SBATCH -e logs/call_variants_marm_%a.err

#load modules
module load apptainer

#set working directory and file structure
WORKDIR=$1
mkdir -p $WORKDIR/variants/marm

mapfile -t BAMS < <(ls $WORKDIR/haplotype/Marm/mito_dge/*_marm_dedup.bam)

bam="${BAMS[$SLURM_ARRAY_TASK_ID]}"
sample_name=$(basename "$bam" | cut -d "_" -f "1,2")

apptainer exec \
      --cleanenv \
      --bind /grphome,/nobackup \
      ./docker/deepvariant_1.10.0.sif \
      run_deepvariant \
        --model_type=RNASEQ \
        --ref=$WORKDIR/references/AspMarm/AspMarm.fasta \
        --reads=$bam \
        --output_vcf=$WORKDIR/variants/marm/${sample_name}_marm.vcf.gz \
        --disable_small_model \
        --num_shards=16
