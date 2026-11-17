#!/bin/bash

# Agent policy: see BYU_ORC_AGENTS.md at the repository root.
#
# STEP 08 - RUN ON A LOGIN NODE, NOT WITH SBATCH.
# Compute nodes have no internet access, so this step downloads the BioGRID
# data once and saves it as an intermediate file that step 09 reads:
#     $WORKDIR/analysis/biogrid/biogrid_raw_interactions.csv
# It is a few small API requests (~15 s), well within login-node limits.
# See README_BIOGRID.md for details.
#
# Needs the BioGRID key in $BIOGRID_ACCESS_KEY or ~/.config/biogrid/access_key.
#
# Usage (from 3_MITO_DGE/scripts/): bash 08_biogrid_fetch.sh <WORKDIR>

set -eo pipefail

if [[ -n "$SLURM_JOB_ID" ]]; then
    echo "ERROR: 08_biogrid_fetch.sh needs internet access; run it on a login node with 'bash', not sbatch." >&2
    exit 1
fi

WORKDIR=${1%/}
if [[ -z "$WORKDIR" ]]; then
    echo "Usage: $0 <WORKDIR>" >&2
    exit 1
fi

module load miniforge3
eval "$(conda shell.bash hook)"
mamba activate python

SCRIPT_DIR=$(dirname "$(realpath "$0")")
python3 "$SCRIPT_DIR/08_biogrid_fetch.py" "$WORKDIR/analysis/biogrid/biogrid_raw_interactions.csv"
