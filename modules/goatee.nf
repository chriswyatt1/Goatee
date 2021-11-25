process ORTHOFINDER {
    publishDir "$params.outdir/Orthofinder/"
    label 'orthofinder'
    stageInMode 'copy'
    
    input:
        path("Directory_protein_fastas")
        
    output:
        path("My_result/*/Orthogroups/Orthogroups.tsv") , emit: orthologues

    script:
    """
        if ls ${Directory_protein_fastas}/*.gz 1> /dev/null 2>&1; then
        gunzip ${Directory_protein_fastas}/*.gz;
        else
        echo "No files to gunzip, proceed."
        fi
        orthofinder -f ${Directory_protein_fastas} -o My_result
    """
}