import pandas as pd
import random
import math

# Use traits list to get a list of taxa to include in tree
trait_taxa = snakemake.params["trait_taxa"]

# Count number of relevant taxa per gene alignment
gene_taxa_counts = []

for gene in snakemake.params["genes_list"]["gene"].tolist():
    gene_file = snakemake.params["genes_list"].loc[gene, "path"]
    taxa_present = []
    with open(gene_file, "r") as file:
        for line in file:
            if any(taxon in line for taxon in trait_taxa):
                taxa_present.append(line.strip())
    gene_taxa_counts.append((gene, len(taxa_present)))

gene_taxa_counts = pd.DataFrame(gene_taxa_counts, columns=["gene", "count"])

# Set up gene requirements and filter genes allowed in tree
n_genes = snakemake.config["params"]["tree_inference"]["n_genes"]

min_prop_taxa = snakemake.config["params"]["tree_inference"]["min_prop_taxa"]

max_taxa = max(gene_taxa_counts["count"])

min_taxa = math.ceil(max_taxa * min_prop_taxa)

filtered_genes = gene_taxa_counts.loc[
    gene_taxa_counts["count"] >= min_taxa, "gene"
].tolist()

# Set randomness seed if present
if snakemake.config["params"]["tree_inference"]["seed"]:
    random.seed(snakemake.config["params"]["tree_inference"]["seed"], version=2)

# Randomly select genes for tree
if len(filtered_genes) <= n_genes:
    random_genes = filtered_genes
else:
    random_genes = random.sample(filtered_genes, n_genes)

# Print genes to file
with open(snakemake.output["genes"], "w") as file:
    for gene in random_genes:
        gene_file = snakemake.params["genes_list"].loc[gene, "path"]
        file.write(f"{gene_file}\n")
