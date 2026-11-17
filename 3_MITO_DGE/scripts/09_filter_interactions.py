#!/usr/bin/env python3
"""Keep BioGRID interactions between one mtDNA gene and one nuclear gene.

Replaces BioGrid_Interactions/1_filter_out_double_nuc.py and
2_filter_double_mito.py with a single filter: an interaction is kept when
exactly one partner is one of the 37 mtDNA genes (any alias). Each row is
oriented nuclear gene -> MT partner, and MT aliases (COX1, ND1, ...) are
reported as the canonical MT- symbol.

Usage: python3 09_filter_interactions.py <biogrid_raw_interactions.csv> <mito_nuclear_interactions.csv>

Agent policy: see BYU_ORC_AGENTS.md at the repository root.
"""

import sys
from pathlib import Path

import pandas as pd

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mt_genes import ALIAS_TO_MT  # noqa: E402

OUT_COLUMNS = [
    "NUCLEAR_GENE",
    "MT_GENE",
    "INTERACTION_ID",
    "EXPERIMENTAL_SYSTEM",
    "THROUGHPUT",
    "PUBMED_ID",
    "PUBMED_AUTHOR",
    "QUALIFICATIONS",
]


def main():
    if len(sys.argv) != 3:
        sys.exit(f"Usage: {sys.argv[0]} <raw_csv> <out_csv>")
    raw_csv, out_csv = sys.argv[1], sys.argv[2]

    df = pd.read_csv(raw_csv, dtype=str, keep_default_na=False)
    a_mt = df["OFFICIAL_SYMBOL_A"].isin(ALIAS_TO_MT)
    b_mt = df["OFFICIAL_SYMBOL_B"].isin(ALIAS_TO_MT)

    a_side = df[a_mt & ~b_mt].assign(
        NUCLEAR_GENE=lambda d: d["OFFICIAL_SYMBOL_B"],
        MT_GENE=lambda d: d["OFFICIAL_SYMBOL_A"].map(ALIAS_TO_MT),
    )
    b_side = df[b_mt & ~a_mt].assign(
        NUCLEAR_GENE=lambda d: d["OFFICIAL_SYMBOL_A"],
        MT_GENE=lambda d: d["OFFICIAL_SYMBOL_B"].map(ALIAS_TO_MT),
    )
    out = (
        pd.concat([a_side, b_side])[OUT_COLUMNS]
        .sort_values(["NUCLEAR_GENE", "MT_GENE", "INTERACTION_ID"])
        .reset_index(drop=True)
    )
    out.to_csv(out_csv, index=False)

    print(f"raw interactions: {len(df)}")
    print(f"  both partners mtDNA (dropped): {int((a_mt & b_mt).sum())}")
    print(f"  neither partner mtDNA (dropped): {int((~a_mt & ~b_mt).sum())}")
    print(f"mito-nuclear interactions kept: {len(out)} "
          f"({out['NUCLEAR_GENE'].nunique()} nuclear genes, {out['MT_GENE'].nunique()} MT genes) -> {out_csv}")


if __name__ == "__main__":
    main()
