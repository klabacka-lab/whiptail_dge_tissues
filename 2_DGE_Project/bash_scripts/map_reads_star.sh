#!/bin/bash
# This file maps the reads to the reference genome

#set working directory
WORKDIR="$1"

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

STAR --runThreadN 8 \
  --runMode genomeGenerate \
  --genomeDir "$WORKDIR/references/AspMarm" \
  --genomeFastaFiles "$WORKDIR/references/AspMarm/AspMarm.fasta" \
  --sjdbGTFfile "$WORKDIR/references/AspMarm/AspMarm.gtf" \
  --sjdbOverhang 100

STAR --runThreadN 8 \
  --runMode genomeGenerate \
  --genomeDir "$WORKDIR/references/AspSept" \
  --genomeFastaFiles "$WORKDIR/references/AspSept/AspSept.fasta" \
  --sjdbGTFfile "$WORKDIR/references/AspSept/AspSept.gtf" \
  --sjdbOverhang 100

#############
# map reads #
#############

# This creats .bam files for the merged and the unmerged reads, .sam files are not created. 
# Our original samples were titled "Am_01_merged..."

echo "Aligning Merged Reads against References with STAR"
echo ""

cd "$WORKDIR/cleaned_reads/merged_reads"
for merged_read in *.fastq.gz; do
  sample_name=$(echo $merged_read | cut -d "_" -f "1,2" )

# map merged clean reads
STAR --genomeDir "$WORKDIR/references/AspMarm" \
  --runThreadN 8 \
  --readFilesIn  "$WORKDIR/cleaned_reads/merged_reads/$merged_read" \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix "$WORKDIR/mapped_reads/${sample_name}_Marm_m"

STAR --genomeDir "$WORKDIR/references/AspSept" \
  --runThreadN 8 \
  --readFilesIn  "$WORKDIR/cleaned_reads/merged_reads/$merged_read" \
  --readFilesCommand zcat \
  --outSAMtype BAM SortedByCoordinate \
  --quantMode GeneCounts \
  --outFileNamePrefix "$WORKDIR/mapped_reads/${sample_name}_Sept_m"

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

done


echo "Alignment completed successfully."