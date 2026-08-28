#!/bin/bash
#cd into the raw data for the project

## Move all of the raw reads from this directory into $d/raw_reads
## MOVE not COPY

##############################
# load all necessary modules #
##############################

module load fastqc/0.11.4
module load fastp/0.20.1

echo ""
echo "Beginning script"
echo ""

#set working directory
$WORKDIR="$1"

begin=`date +%s` # record start time


###################################
# Quality check of raw read files #
###################################

echo "Perform quality check of raw read files\n"
echo ""

# Move to the directory containing the raw reads, should be created in {w} environment_setup.sh
cd /scratch/general/nfs1/utu_4310/whiptail_dge_working_directory/raw_reads

# Create a list of sample names
ls *.fq.gz | cut -d "_" -f 1,2  | uniq > sample_list.txt

# Perform FastQC on each sample
while read i; do 
  	fastqc "$i"_1.fq.gz 
  	fastqc "$i"_2.fq.gz 
done<sample_list.txt

####################################################
# Trimming downloaded Illumina datasets with fastp #
####################################################

echo "Trimming downloaded Illumina datasets with fastp."
ls *.fq.gz | cut -d "." -f "1" | cut -d "_" -f "1,2" | sort | uniq > fastq_list
while read z ; do 
fastp -i "$z"_1.fq.gz -I "$z"_2.fq.gz \
      -m --merged_out ${d}/cleaned_reads/merged_reads/"$z"_merged.fastq \
      --out1 ${d}/cleaned_reads/unmerged_reads/"$z"_unmerged1.fastq --out2 ${d}/cleaned_reads/unmerged_reads/"$z"_unmerged2.fastq \
      -e 25 -q 15 \
      -u 40 -l 15 \
      --adapter_sequence AGATCGGAAGAGCACACGTCTGAACTCCAGTCA \     # These are the adapter_sequences used by Illumina
      --adapter_sequence_r2 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \  # ie. Illumina data was used
      -M 20 -W 4 -5 -3 \
      -c 
cd ../cleaned_reads/merged_reads
gzip "$z"_merged.fastq
cd ../../raw_reads
done<fastq_list
cd ..
echo ""



#######################################
# Quality check of cleaned read files #
#######################################

echo "Perform check of cleaned read files"
cd ${d}/cleaned_reads/merged_reads
pwd
while read i; do 
	fastqc "$i"_merged.fastq.gz 
done<${d}/raw_reads


######################
# Unload all modules #
######################

module unload fastqc/0.11.4
module unload fastp/0.20.1
