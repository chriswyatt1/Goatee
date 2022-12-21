process GO_ASSIGN {
    label 'go_assignment'
    publishDir "$params.outdir/Go/"
    stageInMode 'copy'
    
    input:
        path Go_files
        path Orthogroups
        path Focal

    output:
        path("${Focal}_Result_All_Combine_GO_format") , emit: go_hash

    script:
    """
        perl -pe 's/\r\n|\n|\r/\n/g' ${Orthogroups} > Orthogroups.nomac.tsv
	    Goatee_ortho_go_match.pl Orthogroups.nomac.tsv ${Focal}
    """
}
