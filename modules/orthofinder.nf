nextflow.enable.dsl = 2

process ORTHOFINDER {
    label 'orthofinder'
    publishDir "$params.outdir/Orthofinder/"
    //stageInMode 'copy'
    
    input:
        tuple val("Sample_name"), path("protein_fastas")
               
    output:
        path("My_result/*/Orthogroups/Orthogroups.tsv") , emit: orthologues

    script:
    """
        
        if ls ${protein_fastas}/*.gz 1> /dev/null 2>&1; then
        gunzip ${protein_fastas}/*.gz;
        else
        echo "No files to gunzip, proceed."
        fi
        # orthofinder -f . -o My_result
    """
}