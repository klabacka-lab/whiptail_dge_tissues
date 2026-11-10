#!/bin/bash

#SBATCH --time=00:30:00   # walltime
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH -J "merge_snp_tables"   # job name
#SBATCH -o logs/merge_snp_tables.out
#SBATCH -e logs/merge_snp_tables.err

# Agent policy: see BYU_ORC_AGENTS.md at the repository root.
#
# Merges the per-tissue and per-county SNP CSVs from 06_snp_table.sh (marm and
# sept) into one table: $WORKDIR/analysis/snp_tables/all_mito_snps.csv
#
# Every individual appears in exactly one tissue file AND one county file, so the
# same row exists twice across the 12 inputs. Exact duplicate rows are dropped;
# the result must equal the summed row count of the tissue files (SM+L+H) for
# both genomes, otherwise the script fails.
#
# Usage: sbatch 07_merge_snp_tables.sh <WORKDIR>

set -eo pipefail

WORKDIR=${1%/}
if [[ -z "$WORKDIR" ]]; then
    echo "Usage: $0 <WORKDIR>" >&2
    exit 1
fi

OUTDIR=$WORKDIR/analysis/snp_tables
OUT=$OUTDIR/all_mito_snps.csv
mkdir -p "$OUTDIR"

INPUTS=()
EXPECTED=0
for GENOME in marm sept; do
    TABLES=$WORKDIR/variants/$GENOME/filtered/snp_tables
    for NAME in SM L H culberson SantaFe brewster; do
        f=$TABLES/${NAME}_protein_snps.csv
        if [[ ! -f "$f" ]]; then
            echo "ERROR: missing input $f (run 06_snp_table.sh first)" >&2
            exit 1
        fi
        INPUTS+=("$f")
    done
    # Tissue files alone contain every individual exactly once
    for NAME in SM L H; do
        EXPECTED=$((EXPECTED + $(wc -l < "$TABLES/${NAME}_protein_snps.csv") - 1))
    done
done

# Keep the first header, drop the other headers and exact duplicate rows (order preserved)
awk 'FNR == 1 { if (NR == 1) print; next } !seen[$0]++' "${INPUTS[@]}" > "$OUT.tmp"

ROWS=$(($(wc -l < "$OUT.tmp") - 1))
echo "Merged ${#INPUTS[@]} tables -> $ROWS rows (expected $EXPECTED)"
if [[ "$ROWS" -ne "$EXPECTED" ]]; then
    echo "ERROR: merged row count $ROWS != expected $EXPECTED; leaving $OUT.tmp for inspection" >&2
    exit 1
fi

mv "$OUT.tmp" "$OUT"
echo "Wrote $OUT"
