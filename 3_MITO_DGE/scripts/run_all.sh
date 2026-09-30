#!/bin/bash

#SBATCH --time=48:00:00   # walltime
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G   # memory per CPU core
#SBATCH -J "mito_dge"   # job name
#SBATCH -o logs/mito_dge.out
#SBATCH -e logs/mito_dge.err
#SBATCH --mail-user=vanwper@byu.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#load modules and environment
module load miniforge3


#set working dir
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
if [[ -z "$WORKDIR" ]]; then
    echo "Error: -d <directory> is required." >&2
    usage
fi


#merge ref and alt bams for each sample
mamba activate samtools_env
bash 00_merge_bams.sh $WORKDIR
echo "Alt and Ref bams named and merged"

#