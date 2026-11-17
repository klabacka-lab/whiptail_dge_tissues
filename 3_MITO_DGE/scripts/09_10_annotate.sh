#!/bin/bash

#SBATCH --time=00:30:00   # walltime
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH -J "biogrid_annotate"   # job name
#SBATCH -o logs/biogrid_annotate.out
#SBATCH -e logs/biogrid_annotate.err

# Agent policy: see BYU_ORC_AGENTS.md at the repository root.
#
# Steps 09 + 10: filter the BioGRID download to mito-nuclear interactions, then
# annotate every SNP in all_mito_snps.csv. Needs the intermediate file from
# step 08 (run 08_biogrid_fetch.sh on a login node first; see README_BIOGRID.md).
#
# Inputs:  $WORKDIR/analysis/biogrid/biogrid_raw_interactions.csv   (step 08)
#          $WORKDIR/analysis/snp_tables/all_mito_snps.csv           (step 07)
# Outputs: $WORKDIR/analysis/biogrid/mito_nuclear_interactions.csv
#          $WORKDIR/analysis/snp_tables/all_mito_snps_annotated.csv
#          $WORKDIR/analysis/snp_tables/all_mito_snps_interacting.csv
#
# Usage (from 3_MITO_DGE/scripts/): sbatch 09_10_annotate.sh <WORKDIR> [Human.MitoCarta3.0.csv]

set -eo pipefail

WORKDIR=${1%/}
MITOCARTA=${2:-../../Human.MitoCarta3.0.csv}
if [[ -z "$WORKDIR" ]]; then
    echo "Usage: $0 <WORKDIR> [Human.MitoCarta3.0.csv]" >&2
    exit 1
fi

RAW=$WORKDIR/analysis/biogrid/biogrid_raw_interactions.csv
INTER=$WORKDIR/analysis/biogrid/mito_nuclear_interactions.csv
SNPS=$WORKDIR/analysis/snp_tables/all_mito_snps.csv

for f in "$RAW" "$SNPS" "$MITOCARTA"; do
    if [[ ! -s "$f" ]]; then
        echo "ERROR: missing input $f" >&2
        [[ "$f" == "$RAW" ]] && echo "Run 'bash 08_biogrid_fetch.sh $WORKDIR' on a login node first (see README_BIOGRID.md)." >&2
        exit 1
    fi
done

module load miniforge3
eval "$(conda shell.bash hook)"
mamba activate python

SCRIPT_DIR=${SLURM_SUBMIT_DIR:-$(dirname "$(realpath "$0")")}

echo "== step 09: filter interactions"
python3 "$SCRIPT_DIR/09_filter_interactions.py" "$RAW" "$INTER"

echo "== step 10: annotate SNPs"
python3 "$SCRIPT_DIR/10_annotate_snps.py" "$SNPS" "$INTER" "$MITOCARTA" "$WORKDIR/analysis/snp_tables"
