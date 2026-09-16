#!/bin/bash

#SBATCH --time=72:00:00   # walltime
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G   # memory per CPU core
#SBATCH -J "run_dge_analysis"   # job name
#SBATCH -o logs/run_analysis.out
#SBATCH -e logs/run_analysis.err
#SBATCH --mail-user=vanwper@byu.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#load modules and environment
module load miniforge3
mamba activate dge_r_analysis

Rscript 