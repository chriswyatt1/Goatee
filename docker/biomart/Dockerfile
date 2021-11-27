FROM mambaorg/micromamba:0.13.1

COPY docker/biomart/R-base_micro.yml R-base_micro_h.yml

RUN micromamba install -y -n base -f R-base_micro_h.yml && \
    micromamba clean --all --yes

RUN Rscript -e "install.packages(c('BiocManager'), repos = 'https://cloud.r-project.org/')"
RUN Rscript -e "BiocManager::install('biomaRt')"
