process ORTHOFINDER {
    publishDir "$params.outdir/Orthofinder/"
    label 'orthofinder'

    input:
        path("Directory_target_fasta")
        val("Directory_protein_fastas")
        
    output:
        path("*.csv") , emit: orthologues

    script:
    """
        orthofinder -f ${Directory_protein_fastas}
    """
}