process GET_DATA {
    label 'get_data_biomaRt'
    
    input:
        val(ensembl_repo)
        val(ensembl_host)
        val(public_species)
        
    output:
        path("*.fa.gz") , emit: fasta_files
        path("*.txt") , emit: gene_ontology_files

    script:
    """
        #!/usr/bin/env Rscript 
        library(biomaRt)
        ensembl_entry <- useEnsembl(biomart = "$ensembl_repo", dataset="$public_species", mirror="uswest" , host="$ensembl_host")
        get_go_ids <- getBM(attributes = c('ensembl_gene_id','go_id'), mart = ensembl_entry)
        write.table(bazooka, "go_hash.txt", row.names=T, quote=F, sep="\t" )
        
        d<-unique(bazooka\$ensembl_gene_id)
        new_ids<- split(d, ceiling(seq_along(d)/500))

        for(i in 1:length(new_ids)) {
        bazooka2 <- getBM(attributes = c('ensembl_gene_id','peptide'), mart = ensembl_apis, values=new_ids2[i], filters='ensembl_gene_id',  uniqueRows=T)
        outname <- paste("Myoutput_", i, ".fasta", sep="")
        write.table(bazooka2, file=outname, row.names=F, quote=F, sep="\n")
        }
    """
}
