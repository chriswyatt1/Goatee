process GO_ASSIGN {
    label 'go_assignment'
    publishDir "$params.outdir/Go/"
    stageInMode 'copy'
    
    input:
        path '*.go.txt'
        path 'Orthogroups.tsv'
        path 'Focal_fasta'

    output:
        path("Go_hash.tsv") , emit: go_hash

    script:
    """
        ls
    """
}
