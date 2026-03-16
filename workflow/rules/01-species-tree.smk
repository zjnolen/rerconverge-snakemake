rule select_genes_for_species_tree_inference:
    input:
        genes_list["path"].tolist(),
    output:
        genes="results/{dataset}/01-tree-inference/genes_for_tree_inference.txt",
    params:
        trait_taxa=traits["taxa"].tolist(),
        genes_list=genes_list,
    container:
        pandas_container
    script:
        "../scripts/select_species_tree_genes.py"


rule concatenate_selected_genes_for_tree_inference:
    input:
        genes="results/{dataset}/01-tree-inference/genes_for_tree_inference.txt",
    output:
        fa="results/{dataset}/01-tree-inference/genes_for_tree_inference.fa",
        occ="results/{dataset}/01-tree-inference/genes_for_tree_inference.occupancy",
        part="results/{dataset}/01-tree-inference/genes_for_tree_inference.partition",
    localrule: True
    container:
        phykit_container
    params:
        prefix=lambda w, input: os.path.splitext(input[0])[0],
    shell:
        """
        phykit create_concatenation_matrix \
            -a {input.genes} \
            -p {params.prefix}
        """


rule infer_species_tree:
    input:
        fa="results/{dataset}/01-tree-inference/genes_for_tree_inference.fa",
        part="results/{dataset}/01-tree-inference/genes_for_tree_inference.partition",
    output:
        tree="results/{dataset}/01-tree-inference/{dataset}-tree/{dataset}.treefile",
        outdir=directory("results/{dataset}/01-tree-inference/{dataset}-tree"),
    container:
        iqtree_container
    threads: 4
    params:
        prefix=lambda w, output: os.path.splitext(output.tree)[0],
    resources:
        runtime="2d",
    shell:
        """
        iqtree -m TEST -nt AUTO -s {input.fa} -p {input.part} \
            --prefix {params.prefix}
        """


rule link_dataset_species_tree:
    input:
        get_species_tree,
    output:
        tree="results/{dataset}/{dataset}-species-tree.treefile",
    localrule: True
    container:
        coreutils_container
    shell:
        """
        ln -sr {input} {output}
        """
