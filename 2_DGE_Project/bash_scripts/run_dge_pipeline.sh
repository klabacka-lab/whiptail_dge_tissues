#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=99:00:00
#SBATCH -o slurm-%j.out-%N
#SBATCH -e slurm-%j.err-%N

set -euo pipefail

#load modules and activate required mamba environment
module load miniforge3
mamba activate dge_environment

WORKDIR=""

# Function to show usage information
usage() {
    echo "Usage: $0 -d <directory>"
    echo "  -d <directory>: Set the working directory (required)"
    exit 1
}

# Parse command-line options
while getopts "d:" opt; do
    case $opt in
        d) WORKDIR=$OPTARG ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

# Set working directory
if [[ -z "$WORKDIR"]]; then
    echo "Error: -d <directory> is required." >&2
    usage
fi

# Sets up the file structure for mapping results
bash environment_setup.sh "$WORKDIR"

# Trims the reads and puts them in merged_reads
bash trim_rna_reads.sh "$WORKDIR"

#index the references
sbatch --wait index_refs.sh "$WORKDIR"

# M is the number of merged read files
M=$(ls "$WORKDIR/cleaned_reads/merged_reads"/*.fastq.gz | wc -l)
echo "Found $M merged reads"

# Maps the merged reads to the reference genomes
sbatch --wait --array=0-$((M-1))%10 map_merged_star.sh "$WORKDIR"

# U is the number of unmerged pairs of reads
U=$(ls "$WORKDIR/cleaned_reads/unmerged_reads"/*_unmerged1.fastq | wc -l)
echo "Found $U unmerged pairs"

# Maps the unmerged pairs of reads to the reference genomes
sbatch --wait --array=0-$((U-1))%10 map_unmerged_star.sh "$WORKDIR"

#S is the number of samples to merge
S=$(ls "$WORKDIR/mapped_reads"/*_Marm_m*.bam | sed -E 's|.*/||; s/_Marm_m.*\.bam$//' | sort -u | wc -l)

# Next we had to merge unmerged and merged reads, because there is pair gaps
sbatch --wait --array=0-$((S-1))%10 merge_bams.sh "$WORKDIR"

# Next, we had to count the amount of reads at each location reads were mapped.
# This referent file will likely vary project to project
bash count_reads.sh

#Lastly, Dr. Klabacka helped us with some different statistical analyses, then we used R to generate several graphs.
# The R Script used can be found in the github repo, named "whiptail_dge_R_volcano_plot.r"
