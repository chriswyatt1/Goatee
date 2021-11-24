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
params.target = "$baseDir/data/Human.fa"
params.background = "$baseDir/data/List_of_comparable_species.txt"
params.outdir = "results"


//For CPU and Memory of each process: see conf/optimized_processes.config

log.info """\
 ===================================
 input target sequence                : ${params.target}
 list of background species           : ${params.background}
 out directory                        : ${params.outdir}
 """

//================================================================================
// Include modules
//================================================================================

include { ORTHOFINDER } from './modules/goatee.nf'
include { BUILD_GO_HASH } from './modules/goatee.nf'
include { GO_ENRICHMENT } from './modules/goatee.nf' 

input_target = channel
	.fromPath(params.target)
	.ifEmpty { error "Cannot find any target protein fasta file  matching: ${params.target}" }

input_background_list = channel
	.fromPath(params.background)
	.ifEmpty { error "Cannot find any background list of protein files: ${params.background}" }



workflow {
    ORTHOFINDER ( input_target, input_background_list)
    //BUILD_GO_HASH (ORTHOFINDER.out)
    //GO_ENRICHMENT (BUILD_GO_HASH.out, input_)
}

workflow.onComplete {
	println ( workflow.success ? "\nDone! Open your report in your browser --> $params.outdir/report.html (if you added -with-report flag)\n" : "Hmmm .. something went wrong" )
}

