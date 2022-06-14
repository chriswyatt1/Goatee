process ORTHOFINDER {
    label 'orthofinder'
    publishDir "$params.outdir/Orthofinder/"
    //stageInMode 'copy'
    
    input:
        path '*'
               
    output:
        path("My_result/*/Orthogroups/Orthogroups.tsv") , emit: orthologues

    script:
    """
        gunzip *.gz
        orthofinder -f . -o My_result
    """
}
