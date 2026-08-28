#!/bin/bash

#####################
# Environment Setup #
#####################

# cd into the desired working directory
WORKDIR="$1"

cd $WORKDIR

mkdir -p cleaned_reads
mkdir -p cleaned_reads/merged_reads
mkdir -p cleaned_reads/unmerged_reads
mkdir -p haplotypes
mkdir -p mapped_reads
mkdir -p variants