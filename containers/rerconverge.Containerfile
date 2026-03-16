FROM rocker/r-ver:4.5.1

RUN apt-get update && apt-get install -y libglpk40 && \
    R -q -e 'install.packages(c("devtools", "BiocManager"))' && \
    R -q -e 'BiocManager::install(c("ggtree", "impute"), ask = FALSE)' && \
    R -q -e 'devtools::install_github("nclark-lab/RERconverge", ref = "251bae1")'