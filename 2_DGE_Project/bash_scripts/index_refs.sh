#!/bin/bash

#SBATCH --time=10:00:00   # walltime
#SBATCH --cpus-per-task=16
#SBATCH --mem=48G   # memory per CPU core
#SBATCH -J "index_refs"   # job name
# Indexes the Reference files

set -euo pipefail

#set working directory
WORKDIR="$1"

module load miniforge3
mamba activate dge_environment

##########################
# Index reference genome #
##########################

echo "Indexing Reference"
echo ""


###################################
# convert gff to gtf for indexing #
###################################

# This can be passed over if the file is already a .gtf file.
cd "$WORKDIR/references/AspMarm"
gffread -T AspMarm.gff -o AspMarm.gtf

cd "$WORKDIR/references/AspSept"
gffread -T AspSept.gff3 -o AspSept.gtf

################
# index genomes #
################

STAR --runThreadN 16 \
  --runMode genomeGenerate \
  --genomeDir "$WORKDIR/references/AspMarm" \
  --genomeFastaFiles "$WORKDIR/references/AspMarm/AspMarm.fasta" \
  --sjdbGTFfile "$WORKDIR/references/AspMarm/AspMarm.gtf" \
  --sjdbOverhang 100

STAR --runThreadN 16 \
  --runMode genomeGenerate \
  --genomeDir "$WORKDIR/references/AspSept" \
  --genomeFastaFiles "$WORKDIR/references/AspSept/AspSept.fasta" \
  --sjdbGTFfile "$WORKDIR/references/AspSept/AspSept.gtf" \
  --sjdbOverhang 100