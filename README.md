This is a Nextflow pipeline to run non-model organism Gene Ontology

When working with Human and Mouse, there are plentiful resources to take advantage of. Yet, for non-model organisms, it can take a long time to build the resources needed to analyse a new species. 

This pipeline aims to create a simple procedure to build a Gene ontology database for a new species. Then you can use it to produce blast hits with a few different programs to compare and contrast them.


To run nextflow:

```
nextflow run main.nf -bg
```

To test orthofinder options use:
```
docker run -it --rm davidemms/orthofinder:2.5.4 orthofinder -h
docker run -it --rm chriswyatt/goatee_biomart R
```

To get a subset for testing this repo:
```
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' Pig.fasta | awk -F '\t' '{if(index($1,"Olfactory")!=0) printf("%s\n%s\n",$1,$2);}' | gzip > Pig_olfactory.fasta.gz
```

These lines are helpful to explore biomaRt :


To check what species are present and their species name codes:

```
library(biomaRt)
ensembl <- useEnsembl(biomart = "metazoa_mart", host="https://metazoa.ensembl.org")
datasets <- listDatasets(ensembl)
datasets
```

Useful yml for future projects: https://github.com/nf-core/circrna/blob/e36d85792a9f9c2fc317ead0131560fddbae9462/environment.yml
