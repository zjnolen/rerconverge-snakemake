import pandas as pd
import os
import math
from pathlib import Path

# Define containers for easy version verification
rerconverge_container = "docker://ghcr.io/zjnolen/rerconverge:0.3.0-20260106-251bae1"
phykit_container = "docker://quay.io/biocontainers/phykit:2.1.5--pyhdfd78af_0"
iqtree_container = "docker://quay.io/biocontainers/iqtree:3.0.1--h503566f_0"
coreutils_container = "docker://quay.io/biocontainers/coreutils:9.5"

# read in configfile


configfile: "config/config.yaml"


# read in traits

traits = pd.read_table(config["traits"], header=0, sep="\t").set_index(
    "taxon", drop=False
)

# get a list of the trait identifiers

trait_ids = traits.columns[1:].tolist()

# determine if traits should be analyzed as binary or continuous

trait_types = []

for t in trait_ids:
    # Ensure all traits have numeric values
    if not all(isinstance(x, (int, float)) for x in traits[t]):
        raise ValueError(f"Trait values for {t} not numeric.")
    # Set to binary if only two possible values
    elif len({x for x in traits[t] if not math.isnan(x)}) == 2:
        # only do so if two values are 0 and 1, otherwise raise warning
        if {x for x in traits[t] if not math.isnan(x)} == {0, 1}:
            sys.stderr.write(f"Will treat {t} as binary trait.\n")
            trait_type = "binary"
        else:
            raise ValueError(
                f"Trait {t} contains only two possible trait values (binary), "
                f"but is not coded using 0 and 1. Please code this trait using "
                f"0 and 1."
            )
    else:
        sys.stderr.write(f"Will treat {t} as continuous trait.\n")
        trait_type = "continuous"
    trait_types.append(trait_type)

# read in gene list

if os.path.isfile(config["genes"]):
    genes_list = pd.read_table(config["genes"], header=0, sep="\t").set_index(
        "gene", drop=False
    )
elif os.path.isdir(config["genes"]):
    genes = [Path(gene).stem for gene in os.listdir(config["genes"])]
    gene_paths = [f"{config["genes"]}/{gene}" for gene in os.listdir(config["genes"])]
    genes_list = pd.DataFrame({"gene": genes, "path": gene_paths}).set_index(
        "gene", drop=False
    )

# helper functions for different rules


def get_species_tree(wildcards):
    if config["species_tree"] == "infer_tree":
        return expand(
            "results/{dataset}/01-tree-inference/{dataset}-tree/{dataset}.treefile",
            dataset=wildcards.dataset,
        )
    return config["species_tree"]


def get_alignment_ext(wildcards):
    if config["dna_or_aa"] == "DNA" or config["dna_or_aa"] == "dna":
        return "fna"
    if config["dna_or_aa"] == "AA" or config["dna_or_aa"] == "aa":
        return "faa"
