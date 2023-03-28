process GO_EXPANSION {
    label 'go_expansion'
    tag "GO_expansion"
    publishDir "$params.outdir/Go_expansion/"
    stageInMode 'copy'
    errorStrategy = 'ignore'    

    input:
        path Go_counts

    output:
        path("GO_table_counts.tsv") , emit: go_count_table

    script:
    """
	#ls -lash ${Go_counts}
	Expansion_summary.pl
    """
}
