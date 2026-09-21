#!/bin/bash

#SBATCH --time=48:00:00   # walltime
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G   # memory per CPU core
#SBATCH -J "run_dge_analysis"   # job name
#SBATCH -o logs/run_analysis.out
#SBATCH -e logs/run_analysis.err
#SBATCH --mail-user=vanwper@byu.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#load modules and environment
module load miniforge3
mamba activate dge_r_analysis


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


#run a test on the localities, takes 3 arguments: featurecounts output, csv with sample data, and output path + name
#run marm analysis
# Rscript localities_analysis.r "$WORKDIR/analysis/marm_counts.txt" "$WORKDIR/analysis/SampleInfo.csv" "$WORKDIR/analysis/marm_localities.csv"
Rscript dge_R_volcano_plot.R "$WORKDIR/analysis/marm_localities.csv" "Gene expression differences between localities" "$WORKDIR/analysis/marm_localities_volcano.pdf"

# Rscript tissue_type_analysis.r "$WORKDIR/analysis/marm_counts.txt" "$WORKDIR/analysis/SampleInfo.csv" "$WORKDIR/analysis/marm_tissues.csv"
Rscript dge_R_volcano_plot.R "$WORKDIR/analysis/marm_tissues.csv" "Gene expression differences between tissue types" "$WORKDIR/analysis/marm_tissues_volcano.pdf"

#run sept analysis
# Rscript localities_analysis.r "$WORKDIR/analysis/sept_counts.txt" "$WORKDIR/analysis/SampleInfo.csv" "$WORKDIR/analysis/sept_localities.csv"
Rscript dge_R_volcano_plot.R "$WORKDIR/analysis/sept_localities.csv" "Gene expression differences between localities" "$WORKDIR/analysis/sept_localities_volcano.pdf"

# Rscript tissue_type_analysis.r "$WORKDIR/analysis/sept_counts.txt" "$WORKDIR/analysis/SampleInfo.csv" "$WORKDIR/analysis/sept_tissues.csv"
Rscript dge_R_volcano_plot.R "$WORKDIR/analysis/sept_tissues.csv" "Gene expression differences between tissue types" "$WORKDIR/analysis/sept_tissues_volcano.pdf"

