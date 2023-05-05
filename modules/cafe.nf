process CAFE {
    label 'cafe'
    tag "cafe"
    publishDir "$params.outdir/Cafe/"
    stageInMode 'copy'
    errorStrategy = 'ignore'    
    container= 'chriswyatt/cafe_r'

    input:
        path Table
	path tree_newick

    output:
        path("Significant_trees.tre") , emit: cafe_significant_nexus

    script:
    """
	cp  ${tree_newick} pruned_tree
	sed -i 's/.prot.fa.largestIsoform//g' pruned_tree 	
	sed -i 's/.prot.fa.largestIsoform//g' N0.tsv
	perl -pe 's/\\r\\n|\\n|\\r/\\n/g' N0.tsv > N0.ex.tsv

	cafe_prep.R 
	cafe5 --cores 1 -i hog_gene_counts.tsv  -t SpeciesTree_rooted_ultra.txt -o Out_cafe
    """
}
