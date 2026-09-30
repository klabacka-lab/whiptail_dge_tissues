#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G   # memory per CPU core
#SBATCH -J "call_variants_sept"   # job name
#SBATCH -o logs/call_variants_sept.out
#SBATCH -e logs/call_variants_sept.err

#load modules
module load apptainer

#set working directory and file structure
WORKDIR=$1
mkdir -p $WORKDIR/variants/sept

mapfile -t BAMS < <(ls $WORKDIR/haplotype/Sept/mito_dge/*_sept_merged.bam)

bam="${BAMS[$SLURM_ARRAY_TASK_ID]}"
sample_name=$(basename "$bam" | cut -d "_" -f "1,2")

apptainer exec \
      --cleanenv \
      --bind /grphome,/nobackup \
      ./docker/deepvariant_1.10.0.sif \
      run_deepvariant \
        --model_type=RNASEQ \
        --ref=$WORKDIR/references/AspSept/AspSept.fasta \
        --reads=$bam \
        --output_vcf=$WORKDIR/variants/sept/${sample_name}_sept.vcf.gz \
        --disable_small_model \
        --num_shards=16
