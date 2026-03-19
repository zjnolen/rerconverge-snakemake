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

# calculate all RER residuals
pdf(file = snakemake@output[["plot"]])
rerw <- getAllResiduals(
  trees,
  transform = "sqrt", n.pcs = 0, use.weights = TRUE, weights = NULL,
  norm = "scale"
)

charpaths <- char2Paths(traits, trees)

cor_trait <- correlateWithContinuousPhenotype(
  rerw, charpaths, min.sp = 10, winsorizeRER = 3, winsorizetrait = 3
)

cor_trait$gene <- row.names(cor_trait)

cor_trait <- cor_trait[, c("gene", "Rho", "N", "P", "p.adj")]

write.table(
  cor_trait,
  file = snakemake@output[["rho"]], quote = FALSE, sep = "\t"
)
