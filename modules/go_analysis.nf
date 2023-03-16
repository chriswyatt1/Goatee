process GO_ASSIGN {
    label 'go_analysis'
    publishDir "$params.outdir/Go_Analysis/"
    stageInMode 'copy'
    
    input:
        path Go_files
        path Orthogroups

    output:
        path("${Focal}_Result_All_Combine_GO_format") , emit: go_hash

    script:
    """
        perl Go_analysis_setup ${Orthogroups} 
	Goatee_ortho_go_match.pl Orthogroups.nomac.tsv ${Focal}
    """
}
