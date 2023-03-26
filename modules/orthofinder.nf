process ORTHOFINDER {
    label 'orthofinder'
    publishDir "$params.outdir/Orthofinder/"
    stageInMode 'copy'
    
    input:
        path '*'
               
    output:
        path("My_result/*/Orthogroups/Orthogroups.tsv") , emit: orthologues

    script:
    """
	ulimit -Hn
	ulimit -Sn
	echo "ulimit -l 10000" >> /etc/init.d/sgeexecd.frontend
        count=`ls -1 *.gz 2>/dev/null | wc -l`
        if [ \$count != 0 ]
        then
	    gunzip *.gz
        fi

	    orthofinder -f . -o My_result
    """
}
