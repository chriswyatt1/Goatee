/*
 * Copyright (c) 2021
 */
 

 /*
 * Authors:
 * - Chris Wyatt <chris.wyatt@seqera.io>
 */

/* 
 * enable modules 
 */
nextflow.enable.dsl = 2

/*
 * Default pipeline parameters (on test data). They can be overriden on the command line eg.
 * given `params.genome` specify on the run command line `--genome /path/to/Duck_genome.fasta`.
 */
params.focal = "Human_olfactory.fasta.gz"
params.proteins = "$baseDir/olfactory_data/"
params.outdir = "results"


//For CPU and Memory of each process: see conf/optimized_processes.config

log.info """\
 ===================================
 focal species                        : ${params.focal}
 list of background species           : ${params.proteins}
 out directory                        : ${params.outdir}
 """

//================================================================================
// Include modules
//================================================================================

include { ORTHOFINDER } from './modules/goatee.nf'
//include { BUILD_GO_HASH } from './modules/goatee.nf'
//include { GO_ENRICHMENT } from './modules/goatee.nf' 

input_target_name = channel
	.fromPath(params.focal)
	.ifEmpty { error "Cannot find focal protein fasta file  matching: ${params.focal}" }

input_proteins = channel
	.fromPath(params.proteins)
	.ifEmpty { error "Cannot find the list of protein files: ${params.proteins}" }


workflow {
    ORTHOFINDER ( input_proteins )
    //BUILD_GO_HASH (ORTHOFINDER.out)
    //GO_ENRICHMENT (BUILD_GO_HASH.out, input_)
}

workflow.onComplete {
	println ( workflow.success ? "\nDone! Open your report in your browser --> $params.outdir/report.html (if you added -with-report flag)\n" : "Hmmm .. something went wrong" )
}

