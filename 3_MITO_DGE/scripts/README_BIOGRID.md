# BioGRID interaction steps (08–10)

These steps add human protein-interaction information from
[BioGRID](https://thebiogrid.org) to the merged SNP table from step 07
(`$WORKDIR/analysis/snp_tables/all_mito_snps.csv`). They replace the hand-run
scripts in `BioGrid_Interactions/`, which are kept for reference.

**Step 08 must be run by hand on a login node.** Compute nodes have no internet
access, so step 08 cannot run under Slurm or from `run_all.sh`. It downloads the
BioGRID data once and saves it as an intermediate file. Steps 09–10 then run as
a normal Slurm job that reads that file.

## One-time setup: BioGRID access key

1. Get a free key at <https://webservice.thebiogrid.org> if you don't have one.
2. Store it outside the repository, readable only by you:
   ```bash
   mkdir -p ~/.config/biogrid
   echo "YOUR_KEY_HERE" > ~/.config/biogrid/access_key
   chmod 600 ~/.config/biogrid/access_key
   ```
   Alternatively, export `BIOGRID_ACCESS_KEY` in your shell before running step 08.

Never commit the key. `BioGrid_Interactions/biogrid_access.md` is git-ignored for this reason.

## Running

From `3_MITO_DGE/scripts/`, with `WORKDIR` set to the project working directory
(e.g. `/home/vanwper/nobackup/autodelete/dge_tesselatus`):

```bash
# Step 08 — on a LOGIN node, with bash (not sbatch). Takes ~15 seconds.
bash 08_biogrid_fetch.sh $WORKDIR

# Steps 09–10 — submit to Slurm (also called at the end of run_all.sh)
sbatch 09_10_annotate.sh $WORKDIR
```

Step 08 refuses to run inside a Slurm job. Steps 09–10 stop with a message if
step 08's output is missing.

You only need to rerun step 08 to pick up a newer BioGRID release. Rerun 09–10
whenever `all_mito_snps.csv` changes.

## What each step does

| Step | Script | What it does |
|---|---|---|
| 08 | `08_biogrid_fetch.sh` → `08_biogrid_fetch.py` | Queries BioGRID for every human interaction involving the 37 mitochondrial-genome (mtDNA) genes. It leaves out the POSITIVE GENETIC and PHENOTYPIC ENHANCEMENT evidence types and fetches results in pages, so they are never cut off at 10,000. |
| 09 | `09_filter_interactions.py` | Keeps interactions where exactly one partner is an mtDNA gene and the other is nuclear. BioGRID names (COX1, ND1, …) are converted to MT- symbols (MT-CO1, MT-ND1, …). |
| 10 | `10_annotate_snps.py` | Builds one row per gene and joins it onto every SNP row of that gene. It fills GeneType, Official_Symbol, Interaction_Binary, Interaction_Gene and Interaction_Type, and adds SubLocalization from MitoCarta 3.0. |

`09_10_annotate.sh` runs steps 09 and 10 together as a single Slurm job.

`mt_genes.py` holds the 37 mtDNA genes and their aliases, shared by steps 08 and 09.

## Files

| File | Made by | Contents |
|---|---|---|
| `$WORKDIR/analysis/biogrid/biogrid_raw_interactions.csv` | 08 | Raw BioGRID download (intermediate) |
| `$WORKDIR/analysis/biogrid/mito_nuclear_interactions.csv` | 09 | One row per mito–nuclear interaction: `NUCLEAR_GENE, MT_GENE, INTERACTION_ID, EXPERIMENTAL_SYSTEM, THROUGHPUT, PUBMED_ID, PUBMED_AUTHOR, QUALIFICATIONS`. This is where to look up the evidence behind an interaction. |
| `$WORKDIR/analysis/snp_tables/all_mito_snps_annotated.csv` | 10 | Every SNP row with all columns filled |
| `$WORKDIR/analysis/snp_tables/all_mito_snps_interacting.csv` | 10 | Only rows with a non-empty Interaction_Type |

`all_mito_snps.csv` itself is never modified.

## Column meanings (filled by step 10)

- **GeneType** — `MITO` for every row. All genes are nuclear-encoded mitochondrial proteins (MitoCarta 3.0).
- **Official_Symbol** — the HGNC symbol used by BioGRID. This is the same as GENE, or `ERR` if GENE isn't a MitoCarta symbol.
- **Interaction_Binary** — `1` if the gene interacts with an mtDNA-encoded gene in BioGRID, otherwise `0`.
- **Interaction_Gene** — its mtDNA partners separated by `;` (e.g. `MT-CO1;MT-CO2`), or `NA` if it has none.
- **Interaction_Type** — `P` if it has an mtDNA interaction. `R` is added if the gene is on the mitochondrial ribosome / tRNA-synthetase list, or `D` if it is on the mtDNA replication / transcription list (both lists come from the old `4_add_interaction_type.py`). Possible values are `P`, `PR`, `PD`, `R`, `D`, or blank.
- **SubLocalization** — MitoCarta3.0_SubMitoLocalization (e.g. Matrix, MIM).
