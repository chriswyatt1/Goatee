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
	path GO_assign_sp

    output:
        path("Significant_trees.tre") , emit: cafe_significant_nexus

    script:
    """
	#Find out the names of the input go files that we exclude:
	#EXCLUDED=\$(ls *go.txt | sed 's/.go.txt//g' | sed 's/_go.txt//g' | tr "\\n" " ")
	cp  ${tree_newick} pruned_tree
	sed -i 's/.prot.fa.largestIsoform//g' pruned_tree 	
	
	#echo \$EXCLUDED > tbd
	sed -i 's/.prot.fa.largestIsoform//g' N0.tsv
	perl -pe 's/\\r\\n|\\n|\\r/\\n/g' N0.tsv > N0.ex.tsv
	#Filter_outgroup_n0.pl N0.ex.tsv tbd

	cafe_prep.R 
	cafe5 --cores 1 -i hog_gene_counts.tsv  -t SpeciesTree_rooted_ultra.txt -o Out_cafe
    """
}
