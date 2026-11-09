#!/bin/bash

#SBATCH --time=01:00:00   # walltime
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH -J "snp_table"   # job name
#SBATCH -o logs/snp_table.out
#SBATCH -e logs/snp_table.err

# Agent policy: see BYU_ORC_AGENTS.md at the repository root.
#
# Builds a per-individual SNP table (CSV) from each categorized VCF produced by
# 05_categorize_vcf.sh ({tissue}_protein.vcf.gz and {county}_protein.vcf.gz).
# One row per individual x SNP where the individual's genotype carries the alt
# allele (0/1, 1/1, phased or not). No-calls (./.) and 0/0 are dropped.
# Coordinates are BED-style: START = POS-1, END = POS-1+len(REF).
#
# Columns: Tissue,County,IND_ID,REF_GENOME,CHROM,START,END,REF_ALLELE,ALT_ALLELE,
#          GENE,Delta,FieldTag,GeneType,Official_Symbol,Interaction_Binary,
#          Interaction_Gene,Interaction_Type
#   GENE     = human MitoCarta symbol from INFO/GENE (set in 04_bed_filter.sh)
#   Delta    = ref AD - alt AD for that individual
#   FieldTag = RLK### field ID from SampleInfo.csv
#   GeneType .. Interaction_Type are left blank, to be filled by the BioGrid step.
#
# Usage: sbatch 06_snp_table.sh <filtered_dir> <genome_label: marm|sept> [SampleInfo.csv]
# Output: <filtered_dir>/snp_tables/{name}_snps.csv

WORKDIR=$1
GENOME=$2
SAMPLE_INFO=${3:-../../sample_info/SampleInfo.csv}

if [[ -z "$WORKDIR" || -z "$GENOME" ]]; then
    echo "Usage: $0 <filtered_dir> <genome_label> [SampleInfo.csv]" >&2
    exit 1
fi
if [[ ! -f "$SAMPLE_INFO" ]]; then
    echo "Sample info file not found: $SAMPLE_INFO" >&2
    exit 1
fi

module load miniforge3
eval "$(conda shell.bash hook)"
mamba activate bcftools

OUTDIR=$WORKDIR/snp_tables
mkdir -p "$OUTDIR"

HEADER="Tissue,County,IND_ID,REF_GENOME,CHROM,START,END,REF_ALLELE,ALT_ALLELE,GENE,Delta,FieldTag,GeneType,Official_Symbol,Interaction_Binary,Interaction_Gene,Interaction_Type"

for NAME in SM L H culberson SantaFe brewster; do
    VCF=$WORKDIR/${NAME}_protein.vcf.gz
    OUT=$OUTDIR/${NAME}_protein_snps.csv

    if [[ ! -s "$VCF" ]]; then
        echo "WARNING: $VCF missing or empty; writing header-only table" >&2
        echo "$HEADER" > "$OUT"
        continue
    fi

    bcftools query -f '[%SAMPLE\t%CHROM\t%POS\t%REF\t%ALT\t%GT\t%AD\t%INFO/GENE\n]' "$VCF" \
    | awk -v genome="$GENOME" -v header="$HEADER" '
        BEGIN { OFS = "," }
        # First file: SampleInfo.csv (SampleID,SAMPLE,TISSUE,Location,County)
        NR == FNR {
            sub(/\r$/, "")
            if (FNR == 1) next
            split($0, f, ",")
            fieldtag[f[1]] = f[2]
            tissue[f[1]] = f[3]
            county[f[1]] = f[5]
            next
        }
        FNR == 1 { print header }
        # Second stream: bcftools query output (tab-separated)
        {
            split($0, v, "\t")
            if (v[6] !~ /1/) next      # keep only genotypes carrying the alt allele
            t = (v[1] in tissue) ? tissue[v[1]] : "NA"
            c = (v[1] in county) ? county[v[1]] : "NA"
            ft = (v[1] in fieldtag) ? fieldtag[v[1]] : "NA"
            gene = (v[8] == "." || v[8] == "") ? "NA" : v[8]
            if (split(v[7], ad, ",") == 2 && ad[1] != "." && ad[2] != ".")
                delta = ad[1] - ad[2]
            else
                delta = "NA"
            # trailing empty fields: GeneType,Official_Symbol,Interaction_Binary,Interaction_Gene,Interaction_Type
            print t, c, v[1], genome, v[2], v[3] - 1, v[3] - 1 + length(v[4]), v[4], v[5], gene, delta, ft, "", "", "", "", ""
        }
    ' "$SAMPLE_INFO" - > "$OUT"

    # If bcftools produced no rows, awk never saw the stream; ensure a header exists
    [[ -s "$OUT" ]] || echo "$HEADER" > "$OUT"

    echo "$NAME: $(($(wc -l < "$OUT") - 1)) rows -> $OUT"
done
