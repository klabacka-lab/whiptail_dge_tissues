#!/usr/bin/env python3
"""Fill the gene/interaction columns of all_mito_snps.csv.

Replaces BioGrid_Interactions/3_master_filter.py, 4_add_interaction_type.py
and 5_add_sublocalizations.R. Every annotated column depends only on the gene,
so a gene-level table (one row per unique GENE) is built once and left-joined
onto the SNP rows by GENE; SNP rows are never added or dropped.

Columns filled:
  GeneType           MITO for every row (nuclear-encoded mitochondrial proteins)
  Official_Symbol    GENE if it is a MitoCarta3.0 Symbol, else ERR
  Interaction_Binary 1 if the gene has a mito-nuclear BioGRID interaction, else 0
  Interaction_Gene   its MT partners, e.g. "MT-CO1;MT-ND5" (NA if none);
                     per-interaction evidence is in mito_nuclear_interactions.csv
  Interaction_Type   P (interaction) + R (ribosome/tRNA synthetase list) or
                     D (replication/transcription list), same rules as old step 4
  SubLocalization    (new column) MitoCarta3.0_SubMitoLocalization

Outputs:
  <out_dir>/all_mito_snps_annotated.csv    every SNP row
  <out_dir>/all_mito_snps_interacting.csv  rows with non-empty Interaction_Type

Usage: python3 10_annotate_snps.py <all_mito_snps.csv> <mito_nuclear_interactions.csv> <Human.MitoCarta3.0.csv> <out_dir>

Agent policy: see BYU_ORC_AGENTS.md at the repository root.
"""

import sys
from pathlib import Path

import pandas as pd

# Lists copied unchanged from BioGrid_Interactions/4_add_interaction_type.py
D_LIST = {
    "POLRMT", "POLDIP2", "MTERF2", "MTRES1", "TEFM", "TFAM", "POLG", "MTPAP", "MTERF4", "MTERF3", "TFB1M",
    "TFB2M", "POLQ", "POLG2", "MTERF1", "PRIMPOL", "POLB",
}
R_LIST = {
    "MRPL12", "MRPS35", "MRPL53", "MRPS27", "MRPL46", "MRPS23", "IARS2", "MRPS15", "MRPL34", "MRPL2", "LARS2",
    "MRPL43", "MRPL10", "MRPS2", "MRPL16", "MRPL40", "MRPS18A", "MRPL1", "MRPL4", "MRPL55", "MRPL44", "MRPS14",
    "MRPS17", "MRPL17", "MRPL11", "MRPL13", "MRPL33", "MRPS28", "MRPL28", "YARS2", "MRPL21", "MRPS9", "MRPL15",
    "MRPL24", "MRPS7", "MRPL3", "MRPS12", "MRPL49", "MRPL19", "MRPL36", "FARS2", "MRPS18C", "MARS2", "MRPL20",
    "MRPS21", "MRPL30", "MRPS34", "MRPL22", "MRPL47", "MRPL9", "WARS2", "MRPS16", "MRPS5", "MRPS26", "MRPL27",
    "MRPS10", "MRPL37", "MRPL41", "MRPS6", "MRPL23", "DARS2", "MRPL51", "MRPL32", "MRPS25", "CARS2", "MRPS30",
    "NARS2", "MRPL18", "VARS2", "MRPL54", "MRPL38", "MRPL58", "MRPL35", "MRPS11", "SARS2", "MRPL57", "EARS2",
    "HARS2", "MRPL50", "RARS2", "MRPL14", "MRPS24", "MRPS22", "MRPS33", "TARS2", "MRPL39", "MRPL45", "MRPS31",
    "AARS2", "MRPL42", "MRPS18B", "GARS1", "PARS2", "MRPL52", "KARS1", "MRPS36", "MRPL48",
}

ANNOT_COLUMNS = ["GeneType", "Official_Symbol", "Interaction_Binary", "Interaction_Gene", "Interaction_Type"]


def interaction_type(binary, symbol):
    t = "P" if binary == 1 else ""
    if symbol in R_LIST:
        t += "R"
    elif symbol in D_LIST:
        t += "D"
    return t


def main():
    if len(sys.argv) != 5:
        sys.exit(f"Usage: {sys.argv[0]} <all_mito_snps.csv> <interactions.csv> <MitoCarta.csv> <out_dir>")
    snp_csv, inter_csv, mitocarta_csv, out_dir = sys.argv[1:]
    out_dir = Path(out_dir)

    snps = pd.read_csv(snp_csv, dtype=str, keep_default_na=False)
    inter = pd.read_csv(inter_csv, dtype=str, keep_default_na=False)
    mc = pd.read_csv(mitocarta_csv, dtype=str, keep_default_na=False, encoding="utf-8-sig",
                     usecols=["Symbol", "MitoCarta3.0_SubMitoLocalization"])
    sublocal = dict(zip(mc["Symbol"], mc["MitoCarta3.0_SubMitoLocalization"]))

    # MT partners per nuclear gene
    partners = (inter.groupby("NUCLEAR_GENE")["MT_GENE"]
                .agg(lambda s: ";".join(sorted(set(s)))).to_dict())

    # (a) gene-level table: one row per unique GENE
    genes = pd.DataFrame({"GENE": sorted(snps["GENE"].unique())})
    genes["GeneType"] = "MITO"
    genes["Official_Symbol"] = genes["GENE"].where(genes["GENE"].isin(sublocal), "ERR")
    genes["Interaction_Binary"] = genes["Official_Symbol"].isin(partners).astype(int)
    genes["Interaction_Gene"] = genes["Official_Symbol"].map(partners).fillna("NA")
    genes["Interaction_Type"] = [interaction_type(b, s) for b, s in
                                 zip(genes["Interaction_Binary"], genes["Official_Symbol"])]
    genes["SubLocalization"] = genes["Official_Symbol"].map(sublocal).fillna("NA")

    # (b) left-join onto the SNP rows by GENE, replacing the blank placeholder columns
    n_before = len(snps)
    annotated = snps.drop(columns=ANNOT_COLUMNS).merge(genes, on="GENE", how="left", validate="many_to_one")
    assert len(annotated) == n_before, "row count changed during merge"
    annotated = annotated[list(snps.columns) + ["SubLocalization"]]  # keep original column order

    out_dir.mkdir(parents=True, exist_ok=True)
    all_out = out_dir / "all_mito_snps_annotated.csv"
    hit_out = out_dir / "all_mito_snps_interacting.csv"
    annotated.to_csv(all_out, index=False)
    interacting = annotated[annotated["Interaction_Type"] != ""]
    interacting.to_csv(hit_out, index=False)

    print(f"genes: {len(genes)}  (ERR symbols: {(genes['Official_Symbol'] == 'ERR').sum()}, "
          f"with MT interaction: {genes['Interaction_Binary'].sum()})")
    print("genes by Interaction_Type:", genes["Interaction_Type"].replace("", "(none)").value_counts().to_dict())
    print(f"SNP rows: {len(annotated)} -> {all_out}")
    print(f"interacting SNP rows: {len(interacting)} -> {hit_out}")


if __name__ == "__main__":
    main()
