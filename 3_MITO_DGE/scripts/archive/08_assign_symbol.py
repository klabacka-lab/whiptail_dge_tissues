# Author: Baylee Christensen
# Date: 11/15/2024
# Description: This python script takes in the Human Mitocarta file and the
# gene list from the pipeline and appends an official symbol column to
# rd_mito_variants, where the output has the NCBI_symbol suffix.
import pandas as pd

# Load the MitoCarta and variants data
mitocarta = pd.read_csv("Human.MitoCarta3.0.csv")
mitocarta_selected = mitocarta[['Symbol', 'Synonyms']]
variants = pd.read_csv("rd_mito_variants_updated.csv")

# Create a new column in the variants DataFrame
variants['Official_Symbol'] = 'ERR'  # Default value

# Process each gene in the variants file
for index, row in variants.iterrows():
    gene = row['Gene']

    # Check if the gene matches a Symbol
    match_symbol = mitocarta_selected[mitocarta_selected['Symbol'] == gene]
    if not match_symbol.empty:
        variants.at[index, 'Official_Symbol'] = match_symbol.iloc[0]['Symbol']
        continue  # Move to the next gene if a match is found

    # Check if the gene matches a Synonym
    synonym_found = False
    for _, mito_row in mitocarta_selected.iterrows():
        synonyms = str(mito_row['Synonyms']).split('|')  # Split the Synonyms column by '|'
        if gene in synonyms:
            variants.at[index, 'Official_Symbol'] = mito_row['Symbol']
            synonym_found = True
            break  # Exit the loop as we found a match

    # If no match is found, 'Official_Symbol' remains 'ERR'

# Save the updated DataFrame to a new file
variants.to_csv("rd_mito_variants_NCBI_symbol.csv", index=False)

