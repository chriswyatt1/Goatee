This is a Nextflow pipeline to run non-model organism Gene Ontology

When working with Human and Mouse, there are plentiful resources to take advantage of. Yet, for non-model organisms, it can take a long time to build the resources needed to analyse a new species. 

This pipeline aims to create a simple procedure to build a Gene ontology database for a new species. Then you can use it to produce blast hits with a few different programs to compare and contrast them.


To run nextflow:

nextflow run main.nf 


To test orthofinder options use:
 docker run -it --rm davidemms/orthofinder:2.5.4 orthofinder -h