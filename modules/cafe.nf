process CAFE {
    label 'cafe'
    tag "cafe"
    publishDir "$params.outdir/Cafe/"
    stageInMode 'copy'
    errorStrategy = 'ignore'    
    container= 'chriswyatt/cafe'

    input:
        path Table
	path tree_newick
	path GO_assign_sp

    output:
        path("Significant_trees.tre") , emit: cafe_significant_nexus

    script:
    """
	#Find out the names of the input go files that we exclude:
	#ls *.go.txt | sed 's/.go.txt//g' > Excluded_species
	EXCLUDED=\$(ls *go.txt | sed 's/.go.txt//g' | sed 's/_go.txt//g' | tr "\n" " ")
	nw_prune  ${tree_newick} \$EXCLUDED > pruned_tree
	sed -i 's/.prot.fa.largestIsoform//g' pruned_tree 	
	echo \$EXCLUDED
	cat pruned_tree
	cafe5 -c 8 -i $Table -t pruned_tree
    """
}
