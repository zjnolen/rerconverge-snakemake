rule link_alignments:
    input:
        lambda w: genes_list.loc[w.gene, "path"],
    output:
        "results/{dataset}/rerconverge/input_alignments/{gene}.fna",
    container:
        coreutils_container
    localrule: True
    shell:
        """
        ln -sr {input} {output}
        """


rule estimate_phangorn_trees:
    input:
        aln="results/{dataset}/rerconverge/input_alignments/{gene}.fna",
        tree="results/{dataset}/{dataset}-species-tree.treefile",
    output:
        tree="results/{dataset}/rerconverge/phangorn_trees/{gene}.txt",
    container:
        rerconverge_container
    group:
        "phangorn_trees"
    params:
        type=config["dna_or_aa"].upper(),
        submodel_aa=config["params"]["rerconverge_phangorn"]["aa_model"],
        submodel_dna=config["params"]["rerconverge_phangorn"]["dna_model"],
    script:
        "../scripts/estimate_phangorn_trees.R"


rule combine_phangorn_trees:
    input:
        expand(
            "results/{{dataset}}/rerconverge/phangorn_trees/{gene}.txt",
            gene=genes_list.index.tolist(),
        ),
    output:
        "results/{dataset}/rerconverge/phangorn_trees/all_gene_trees.tsv",
    localrule: True
    container:
        coreutils_container
    shell:
        """
        echo {input} | xargs -n 100 cat > {output}
        """


rule rerconverge_binary_trait:
    input:
        traits=config["traits"],
        trees="results/{dataset}/rerconverge/phangorn_trees/all_gene_trees.tsv",
    output:
        rho="results/{dataset}/rerconverge/rho_tables/{dataset}_{trait}_binary.tsv",
    container:
        rerconverge_container
    resources:
        runtime="6h"
    params:
        taxa=traits["taxon"].tolist(),
        trait_values=lambda w: traits[f"{w.trait}"].tolist(),
    script:
        "../scripts/rerconverge_binary.R"


rule rerconverge_continuous_trait:
    input:
        traits=config["traits"],
        trees="results/{dataset}/rerconverge/phangorn_trees/all_gene_trees.tsv",
    output:
        rho="results/{dataset}/rerconverge/rho_tables/{dataset}_{trait}_continuous.tsv",
    container:
        rerconverge_container
    resources:
        runtime="6h"
    params:
        taxa=traits["taxon"].tolist(),
        trait_values=lambda w: traits[f"{w.trait}"].tolist(),
    script:
        "../scripts/rerconverge_continuous.R"
