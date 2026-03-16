library(RERconverge)

alnfiles <- snakemake@input[["aln"]]
treefile <- snakemake@input[["tree"]]
type <- snakemake@params[["type"]]
outfile <- snakemake@output[["tree"]]

if (type == "DNA") {
  submodel <- snakemake@params[["submodel_dna"]]
} else if (type == "AA") {
  submodel <- snakemake@params[["submodel_aa"]]
}

phangorn_tree <- estimatePhangornTreeAll(
  alnfiles = alnfiles,
  treefile = treefile,
  type = type,
  submodel = submodel,
  output.file = outfile
)