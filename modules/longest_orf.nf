process LONGEST {
    label 'longest'
    tag "$fasta"
    container = 'chriswyatt/bioseqio'
    publishDir "$params.outdir/" , mode: "copy"
    debug true

    input:

        path(fasta)

    output:

        path( "${fasta}.largestIsoform.fa" )

    script:
    """
	head -n 1 ${fasta} > tbd

	if grep -q gene= tbd; then
		ncbi_gffread_to_gene_ncbi.pl ${fasta}
	else	
		ncbi_gffread_to_gene_universal.pl ${fasta}
	fi
    """
}
