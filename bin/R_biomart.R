#!/usr/bin/env Rscript 
args = commandArgs(trailingOnly=TRUE)
library(biomaRt)
ensembl_entry <- useEnsembl(biomart = "args[0]", dataset="args[2]", mirror="uswest" , host="args[1]")
get_go_ids <- getBM(attributes = c('ensembl_gene_id','go_id'), mart = ensembl_entry)
write.table(bazooka, "go_hash.txt", row.names=T, quote=F, sep="\t" )

d<-unique(bazooka\$ensembl_gene_id)
new_ids<- split(d, ceiling(seq_along(d)/500))

for(i in 1:length(new_ids)) {
bazooka2 <- getBM(attributes = c('ensembl_gene_id','peptide'), mart = ensembl_apis, values=new_ids2[i], filters='ensembl_gene_id',  uniqueRows=T)
Sys.sleep(runif(1, 5.0, 10))
outname <- paste("Myoutput_", i, ".fasta", sep="")
write.table(bazooka2, file=outname, row.names=F, quote=F, sep="\n")
}