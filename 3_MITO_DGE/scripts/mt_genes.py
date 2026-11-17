"""The 37 human mitochondrial-genome (mtDNA) genes and their aliases.

Shared by 08_biogrid_fetch.py (query list) and 09_filter_interactions.py
(alias -> canonical MT- symbol). Aliases are the same set used by the old
BioGrid_Interactions/1_filter_out_double_nuc.py; BioGRID reports these genes
under short official symbols (COX1, ND1, ...), so every alias is mapped back
to the MT- symbol.

Agent policy: see BYU_ORC_AGENTS.md at the repository root.
"""

# canonical symbol -> aliases (canonical included)
MT_GENES = {
    "MT-ATP8": ["ATP8", "MT-ATP8", "ATPase8", "MTATP8"],
    "MT-ATP6": ["ATP6", "MT-ATP6", "ATPase6", "MTATP6"],
    "MT-CO1": ["COX1", "MT-CO1", "COI", "MTCO1"],
    "MT-CO2": ["COX2", "MT-CO2", "COII", "MTCO2"],
    "MT-CO3": ["COX3", "MT-CO3", "COIII", "MTCO3"],
    "MT-CYB": ["CYTB", "MT-CYB", "MTCYB"],
    "MT-ND1": ["ND1", "MT-ND1", "MTND1"],
    "MT-ND2": ["ND2", "MT-ND2", "MTND2"],
    "MT-ND3": ["ND3", "MT-ND3", "MTND3"],
    "MT-ND4L": ["ND4L", "MT-ND4L", "MTND4L"],
    "MT-ND4": ["ND4", "MT-ND4", "MTND4"],
    "MT-ND5": ["ND5", "MT-ND5", "MTND5"],
    "MT-ND6": ["ND6", "MT-ND6", "MTND6"],
    "MT-RNR1": ["RNR1", "MT-RNR1", "MTRNR1"],
    "MT-RNR2": ["RNR2", "MT-RNR2", "MTRNR2"],
    "MT-TA": ["TRNA", "MT-TA", "MTTA"],
    "MT-TR": ["TRNR", "MT-TR", "MTTR"],
    "MT-TN": ["TRNN", "MT-TN", "MTTN"],
    "MT-TD": ["TRND", "MT-TD", "MTTD"],
    "MT-TC": ["TRNC", "MT-TC", "MTTC"],
    "MT-TE": ["TRNE", "MT-TE", "MTTE"],
    "MT-TQ": ["TRNQ", "MT-TQ", "MTTQ"],
    "MT-TG": ["TRNG", "MT-TG", "MTTG"],
    "MT-TH": ["TRNH", "MT-TH", "MTTH"],
    "MT-TI": ["TRNI", "MT-TI", "MTTI"],
    "MT-TL1": ["TRNL1", "MT-TL1", "MTTL1"],
    "MT-TL2": ["TRNL2", "MT-TL2", "MTTL2"],
    "MT-TK": ["TRNK", "MT-TK", "MTTK"],
    "MT-TM": ["TRNM", "MT-TM", "MTTM"],
    "MT-TF": ["TRNF", "MT-TF"],
    "MT-TP": ["TRNP", "MT-TP", "MTTP"],
    "MT-TS1": ["TRNS1", "MT-TS1", "MTTS1"],
    "MT-TS2": ["TRNS2", "MT-TS2", "MTTS2"],
    "MT-TT": ["TRNT", "MT-TT", "MTTT"],
    "MT-TW": ["TRNW", "MT-TW", "MTTW"],
    "MT-TY": ["TRNY", "MT-TY", "MTTY"],
    "MT-TV": ["TRNV", "MT-TV", "MTTV"],
}

ALIAS_TO_MT = {alias: canon for canon, aliases in MT_GENES.items() for alias in aliases}
