#!/bin/bash
# This file maps the reads to the reference genome

#set working directory
WORKDIR="$1"

##########################
# Load necessary modules #
##########################

module load gffread/0.12.7
module load star/2.7.10a
module load samtools/1.16

##########################
# Index reference genome #
##########################

echo "Indexing Reference"
echo ""


###################################
# convert gff to gtf for indexing #
###################################

# This can be passed over if the file is already a .gtf file.

gffread -T a_marmoratus_AspMarm2.0_v1.gff -o a_marmoratus_AspMarm2.0_v1.gtf

################
# index genome #
################

STAR --runThreadN 8 --runMode genomeGenerate --genomeDir "${w}"/Reference --genomeFastaFiles "${g}" --sjdbGTFfile "${w}"/Reference/a_marmoratus_AspMarm2.0_v1.gtf --sjdbOverhang 100

#############
# map reads #
#############

# This creats .bam files for the merged and the unmerged reads, .sam files are not created. 
# Our original samples were titled "Am_01_merged..."

echo "Aligning Merged Reads against Reference with STAR, using $t threads."
echo ""

cd "${w}"/cleaned_reads/merged_reads
for merged_read in *.fastq.gz; do
    sample_name=$(echo $merged_read | cut -d "_" -f "1,2" )

# map merged clean reads
STAR --genomeDir "${w}"/Reference \
      --runThreadN 8 \
      --readFilesIn  "${w}"/cleaned_reads/merged_reads/$merged_read \
      --readFilesCommand zcat \
      --outSAMtype BAM SortedByCoordinate \
      --quantMode GeneCounts \
      --outFileNamePrefix "${w}"/mapped_reads/${sample_name}_merged_

# map unmerged clean reads
STAR --genomeDir "${w}"/Reference \
      --runThreadN 8 \
      --readFilesIn  "${w}"/cleaned_reads/unmerged_reads/${sample_name}_unmerged1.fastq \
                     "${w}"/cleaned_reads/unmerged_reads/${sample_name}_unmerged1.fastq \
      --readFilesCommand zcat \
      --outSAMtype BAM SortedByCoordinate \
      --quantMode GeneCounts \
      --outFileNamePrefix "${w}"/mapped_reads/${sample_name}_unmerged_

done


echo "Alignment completed successfully."