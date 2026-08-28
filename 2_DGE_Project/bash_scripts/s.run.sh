#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=99:00:00
#SBATCH -o slurm-%j.out-%N
#SBATCH -e slurm-%j.err-%N

set -euo pipefail

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

# Maps the reads to the reference genome
# Ask syrus for what he used for this step
# something like bash $WORK_DIR/bash_scripts/map_reads_star.sh 

# Next we had to merge unmerged and merged reads, because there is pair gaps
cd $WORK_DIR/bash_scripts
bash merge_merged_and_unmerged_merges.sh
# Or you could run the command in parallel by submitting:
# 1. edit s.merge.sh and change to you working directory
# 2. Submitting sbatch s.merge.sh

# Next, we had to count the amount of reads at each location reads were mapped.
# This referent file will likely vary project to project
bash count_reads.sh

#Lastly, Dr. Klabacka helped us with some different statistical analyses, then we used R to generate several graphs.
# The R Script used can be found in the github repo, named "whiptail_dge_R_volcano_plot.r"
