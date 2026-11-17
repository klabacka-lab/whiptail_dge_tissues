#!/usr/bin/env python3
"""Download all human BioGRID interactions involving the 37 mtDNA genes.

Adapted from BioGrid_Interactions/00_biogrid_interactions.py. Differences:
  * queries the 37 mitochondrial-genome genes (includeInteractors=true returns
    every partner), instead of a hard-coded list of ~400 nuclear genes;
  * pages through results (start/max) so the 10,000-row cap can't truncate;
  * reads the access key from $BIOGRID_ACCESS_KEY or ~/.config/biogrid/access_key;
  * standard library only (urllib), no `requests` needed.

Usage: python3 08_biogrid_fetch.py <output_csv>

Agent policy: see BYU_ORC_AGENTS.md at the repository root.
"""

import csv
import json
import os
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mt_genes import MT_GENES  # noqa: E402

BASE_URL = "https://webservice.thebiogrid.org/interactions"
PAGE_SIZE = 10000  # BioGRID maximum per request
KEY_FILE = Path.home() / ".config" / "biogrid" / "access_key"

# Same evidence exclusion as the old script
EXCLUDED_EVIDENCE = ["POSITIVE GENETIC", "PHENOTYPIC ENHANCEMENT"]

COLUMNS = [
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


def access_key():
    key = os.environ.get("BIOGRID_ACCESS_KEY", "").strip()
    if not key and KEY_FILE.is_file():
        key = KEY_FILE.read_text().strip()
    if not key:
        sys.exit(f"No BioGRID access key: set BIOGRID_ACCESS_KEY or create {KEY_FILE}")
    return key


def fetch_page(params, start):
    query = urllib.parse.urlencode({**params, "start": start, "max": PAGE_SIZE})
    req = urllib.request.Request(f"{BASE_URL}?{query}", headers={"User-Agent": "whiptail-dge-biogrid-fetch"})
    with urllib.request.urlopen(req, timeout=300) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main():
    if len(sys.argv) != 2:
        sys.exit(f"Usage: {sys.argv[0]} <output_csv>")
    out_csv = Path(sys.argv[1])
    out_csv.parent.mkdir(parents=True, exist_ok=True)

    params = {
        "accesskey": access_key(),
        "format": "json",
        "geneList": "|".join(MT_GENES),
        "searchNames": "true",
        "searchSynonyms": "true",
        "includeInteractors": "true",
        "interSpeciesExcluded": "true",
        "taxId": 9606,
        "evidenceList": "|".join(EXCLUDED_EVIDENCE),
        "includeEvidence": "false",  # evidenceList = types to exclude
    }

    rows = {}
    start = 0
    pages = 0
    while True:
        page = fetch_page(params, start)
        pages += 1
        if not isinstance(page, dict):
            sys.exit(f"Unexpected BioGRID response on page {pages}: {str(page)[:300]}")
        for interaction_id, rec in page.items():
            rows[interaction_id] = [interaction_id] + [rec.get(c, "") for c in COLUMNS[1:]]
        print(f"page {pages}: start={start}, {len(page)} interactions")
        if len(page) < PAGE_SIZE:
            break
        start += PAGE_SIZE
        time.sleep(1)  # be polite to the API between pages

    with open(out_csv, "w", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow(COLUMNS)
        writer.writerows(rows.values())

    print(f"{len(rows)} unique interactions over {pages} page(s) -> {out_csv}")


if __name__ == "__main__":
    main()
