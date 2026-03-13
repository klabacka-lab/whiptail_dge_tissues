#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Fetch interactions for a specific gene or gene list
"""

import requests
import json
import pandas as pd
from core import config as cfg

request_url = cfg.BASE_URL + "/interactions"

# List of genes to search for
# pulled from humancarta3.0 (https://personal.broadinstitute.org/scalvo/Mit>
geneList = ["AADAT", "AASS", "ABCB6", "ABCB7", "ABCD1", "ABCD3", "ACAA1", "ACACB", "ACAD8", "ACAD9", "ACADM", "ACADS", "ACAT1", "ACLY", "ACOT2", "ACOT7", "ACSF2", "ACSF3", "ACSL1", "ACSM3", "ADHFE1", "AGK", "AGXT2", "AIFM1", "AIFM2", "AKR1B10", "ALDH18A1", "ALDH2", "ALDH5A1", "AMACR", "AMT", "APEX1", "APOO", "ARL2", "ATAD1", "ATP23", "ATP5MC3", "ATP5ME", "ATP5PD", "ATP5PF", "ATP5PO", "AURKAIP1", "BAK1", "BAX", "BCAT2", "BCO2", "BCS1L", "BDH1", "BLOC1S1", "BNIP3", "BOLA1", "BOLA3", "BPHL", "C1QBP", "CASP3", "CASP9", "CBR3", "CCDC51", "CHCHD4", "CHDH", "CHPT1", "CLPB", "CLPP", "CLPX", "CLYBL", "CMC1", "CMC2", "CMC4", "CMPK2", "COA1", "COA4", "COA5", "COA6", "COA7", "COA8", "COQ3", "COQ4", "COQ5", "COQ6", "COQ7", "COQ8A", "COQ9", "COX10", "COX11", "COX14", "COX15", "COX16", "COX17", "COX18", "COX20", "COX5A", "COX5B", "COX8A", "CPT1A", "CPT1C", "CPT2", "CRY1", "CYB5B", "CYCS", "CYP27B1", "DBI", "DCXR", "DDX28", "DECR1", "DELE1", "DGUOK", "DHRS4", "DHX30", "DLD", "DMAC1", "DMAC2L", "DNAJC19", "DNM1L", "DUS2", "ECH1", "ECI1", "ECI2", "ECSIT", "EFHD1", "ERAL1", "ETFA", "ETFB", "ETFDH", "ETHE1", "EXOG", "FAHD1", "FASN", "FASTK", "FDPS", "FDX1", "FDX2", "FHIT", "FIS1", "FKBP8", "FLAD1", "FXN", "GARS1", "GATB", "GATC", "GATD3A", "GCAT", "GCDH", "GCSH", "GFM1", "GHITM", "GLDC", "GLOD4", "GLRX2", "GLRX5", "GPAM", "GPD2", "GPX1", "GPX4", "GRHPR", "GRSF1", "GSTK1", "GSTZ1", "GUF1", "HADH", "HADHA", "HADHB", "HAGH", "HCCS", "HDHD5", "HEBP1", "HEMK1", "HIBCH", "HINT1", "HINT2", "HINT3", "HMGCL", "HOGA1", "HSCB", "HSD17B10", "HSD17B8", "HSDL1", "HSDL2", "HSPA9", "HTRA2", "IDE", "IDH3A", "IDH3B", "IDH3G", "IDI1", "ISCA1", "ISCA2", "ISCU", "IVD", "KYAT3", "LACTB", "LDHB", "LDHD", "LIAS", "LIPT2", "LONP1", "LYRM1", "LYRM2", "LYRM4", "LYRM7", "LYRM9", "MAIP1", "MAVS", "MCAT", "MCCC1", "MCCC2", "MCL1", "MCUB", "MCUR1", "MECR", "METTL8", "MFF", "MFN1", "MFN2", "MGARP", "MGME1", "MGST1", "MGST3", "MICOS13", "MICU1", "MIEF1", "MIEF2", "MIPEP", "MMAA", "MMAB", "MPC1", "MPC2", "MPV17", "MRM2", "MRM3", "MRPL58", "MRS2", "MSRB3", "MTARC2", "MTCH1", "MTCH2", "MTFP1", "MTFR1", "MTG1", "MTG2", "MTHFS", "MTPAP", "MTX1", "MTX2", "MUL1", "MYG1", "MYO19", "NBR1", "NDUFAF1", "NFU1", "NGRN", "NIT1", "NIT2", "NLRX1", "NOA1", "NOCT", "NRDC", "NSUN2", "NT5M", "NUBPL", "NUDT5", "NUDT6", "NUDT9", "OAT", "OPA1", "OPA3", "OXA1L", "OXR1", "PANK2", "PARK7", "PARL", "PCCA", "PCCB", "PDK1", "PDK2", "PDK3", "PDK4", "PDP1", "PDPR", "PDSS2", "PGAM5", "PGS1", "PHB", "PHB2", "PHYH", "PINK1", "PISD", "PMPCB", "PNPO", "PNPT1", "PPIF", "PPM1K", "PPOX", "PPTC7", "PRDX2", "PRDX3", "PRDX4", "PRDX5", "PRDX6", "PRKN", "PTCD1", "PTCD3", "PTGES2", "PTRH2", "PXMP2", "PYURF", "QDPR", "RAB24", "RAB5IF", "RBFA", "RDH14", "RHOT1", "RIDA", "RLK037", "RLK047", "RLK050", "RLK053", "RLK063", "RMND1", "RNASEH1", "ROMO1", "RPIA", "SAMM50", "SARDH", "SCO1", "SCP2", "SDHA", "SDHB", "SDSL", "SFXN4", "SLC25A10", "SLC25A15", "SLC25A28", "SLC25A30", "SLC25A32", "SLC25A41", "SLC25A6", "SLC30A9", "SMDT1", "SMIM8", "SND1", "SOD1", "SPG7", "SQOR", "SSBP1", "STOM", "STX17", "SUOX", "SUPV3L1", "SURF1", "TACO1", "TAZ", "TCAIM", "TEFM", "TFAM", "TFB2M", "TIMM13", "TIMM21", "TIMM23", "TIMM29", "TIMM44", "TIMM50", "TIMM9", "TOMM20", "TOMM22", "TOMM34", "TOMM40", "TOP3A", "TRAP1", "TRMT1", "TRMU", "TRNT1", "TRUB2", "TSPO", "TSTD3", "TUFM", "TXNRD2", "UQCC1", "UQCC2", "UQCC3", "UQCRB", "UQCRC1", "UQCRC2", "UQCRH", "UQCRQ", "VDAC1", "VDAC2", "VDAC3", "VWA8", "YRDC", "MT-ATP8","MT-ATP6","MT-CO1","MT-CO2","MT-CO3","MT-CYB","MT-ND1","MT-ND2","MT-ND3","MT-ND4L","MT-ND4","MT-ND5","MT-ND6","MT-RNR2","MT-TA","MT-TR","MT-TN","MT-TD","MT-TC","MT-TE","MT-TQ","MT-TG","MT-TH","MT-TI","MT-TL1","MT-TL2","MT-TK","MT-TM","MT-TF","MT-TP","MT-TS1","MT-TS2","MT-TT","MT-TW","MT-TY","MT-TV","MT-RNR1","MT-RNR2"]

evidenceList = ["POSITIVE GENETIC", "PHENOTYPIC ENHANCEMENT"]

# These parameters can be modified to match any search criteria following
# the rules outlined in the Wiki: https://wiki.thebiogrid.org/doku.php/biogridrest
params = {
    "accesskey": cfg.ACCESS_KEY,
    "format": "json",
    "geneList": "|".join(geneList),  # Must be | separated
    "searchNames": "true",  # Search against official names
    "includeInteractors": "true",  # Set to true to get any interaction involving EITHER gene, set to false to get interactions between genes
    "interSpeciesExcluded": "true",
    "searchSynonyms": "true",
    "max": 10000, #edited to get up to 10,000 results
    "taxId": 9606,
    "evidenceList": "|".join(evidenceList),  # Exclude these two evidence types
    "includeEvidence": "false",  # If false "evidenceList" is evidence to exclude, if true "evidenceList" is evidence to show
    "includeHeader": "true",
}




r = requests.get(request_url, params=params)
interactions = r.json()

# Create a hash of results by interaction identifier
data = {}
for interaction_id, interaction in interactions.items():
    data[interaction_id] = interaction
    # Add the interaction ID to the interaction record, so we can reference it easier
    data[interaction_id]["INTERACTION_ID"] = interaction_id

# Load the data into a pandas dataframe
dataset = pd.DataFrame.from_dict(data, orient="index")

# Re-order the columns and select only the columns we want to see

columns = [
    "INTERACTION_ID",
    "ENTREZ_GENE_A",
    "ENTREZ_GENE_B",
    "OFFICIAL_SYMBOL_A",
    "OFFICIAL_SYMBOL_B",
    "EXPERIMENTAL_SYSTEM",
    "PUBMED_ID",
    "PUBMED_AUTHOR",
    "THROUGHPUT",
    "QUALIFICATIONS",
]
dataset = dataset[columns]
dataset.to_csv("complete_interaction_list.csv", index=False)
# Pretty print out the results
print(dataset)
