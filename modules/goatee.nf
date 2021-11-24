process ORTHOFINDER {
    publishDir "$params.outdir/Orthofinder/"
    label 'orthofinder'

    input:
        path("Directory_protein_fastas")
        
    output:
        path("My_result/*.csv") , emit: orthologues

    script:
    """
        if [ -f ${Directory_protein_fastas}/*.gz ]; 
        then 
        gunzip ${Directory_protein_fastas}/*.gz;
        else
        print "No GZip files to unzip";
        fi

        orthofinder -f ${Directory_protein_fastas} -o My_result
    """
}