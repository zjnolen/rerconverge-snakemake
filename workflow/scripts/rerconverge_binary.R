library(RERconverge)

# get list of taxa and relevant trait values for this run
taxa <- snakemake@params[["taxa"]]
traits <- snakemake@params[["trait_values"]]

# remove taxa for which there is no trait value for the trait of interest
taxa <- taxa[!is.na(traits)]
traits <- traits[!is.na(traits)]

# read in trees with branch lengths adjusted by phangorn, only include taxa with
# value for trait of interest
trees <- readTrees(snakemake@input[["trees"]], useSpecies = taxa)

# get list of foreground taxa from trait values (1 = foreground, 0 = background)
fg_taxa <- taxa[traits == 1]

# calculate all RER residuals
pdf(file = snakemake@output[["plot"]])
rerw <- getAllResiduals(
  trees,
  transform = "sqrt", n.pcs = 0, use.weights = TRUE, weights = NULL,
  norm = "scale"
)

fg_paths <- foreground2Paths(fg_taxa, trees, clade = "all")

cor_trait <- correlateWithBinaryPhenotype(
  rerw, fg_paths,
  min.sp = 10, min.pos = 2, weighted = "auto",
  winsorizeRER = NULL, winsorizetrait = NULL, bootstrap = FALSE
)

write.table(
  cor_trait,
  file = snakemake@output[["rho"]], quote = FALSE, sep = "\t"
)
