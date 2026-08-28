#!/bin/bash

#####################
# Environment Setup #
#####################

# cd into the desired working directory
WORKDIR="$1"

cd $WORKDIR

mkdir -p raw_reads

#move the raw read files into the raw_reads directory (expects fastq files)
mv *.fq *.fq.gz raw_reads/

mkdir -p cleaned_reads
mkdir -p cleaned_reads/merged_reads
mkdir -p cleaned_reads/unmerged_reads
mkdir -p haplotypes
mkdir -p mapped_reads
mkdir -p variants