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

params.ensembl_repo="metazoa_mart"
params.ensembl_host='https://metazoa.ensembl.org'
params.ensembl_dataset="example.txt"
params.focal = "Branchiostoma_lanceolatum.BraLan2.pep.all.fa.gz"
params.predownloaded_fasta= "./Background_species_folder/*"
params.outdir = "results"
params.download= false


//For CPU and Memory of each process: see conf/optimized_processes.config

log.info """\
 ===================================
 focal species                        : ${params.focal}
 list of background species           : ${params.ensembl_dataset}
 out directory                        : ${params.outdir}
 """

//================================================================================
// Include modules
//================================================================================

include { GET_DATA } from './modules/getdata.nf'
include { ORTHOFINDER } from './modules/orthofinder.nf'
//include { BUILD_GO_HASH } from './modules/goatee.nf'
//include { GO_ENRICHMENT } from './modules/goatee.nf' 


// TEST WHAT TYPE OF PIEPLINE TO RUN 

if (params.download) { 
	
	background_species = channel
	.fromPath(params.ensembl_dataset) 
	.splitText().map{it -> it.trim()}    
	.ifEmpty { error "Cannot find the list of protein files: ${params.ensembl_dataset}" }

	input_host = channel
	.value(params.ensembl_host)
	.ifEmpty { error "Cannot find the list of protein files: ${params.ensembl_host}" }

	input_repo = channel
	.value(params.ensembl_repo)
	.ifEmpty { error "Cannot find the list of protein files: ${params.ensembl_repo}" }
}

input_target_proteins = channel
	.fromPath(params.focal)
	.ifEmpty { error "Cannot find the list of protein files: ${params.focal}" }




workflow {
	if (params.download){
		GET_DATA ( input_repo, input_host, background_species )
		GET_DATA.out.fasta_files.mix(input_target_proteins).collect().view().set{ proteins_ch }
	}
	else{
		channel.fromPath(params.predownloaded_fasta).collect().set{ proteins_ch }
	}
    ORTHOFINDER ( proteins_ch )
    //BUILD_GO_HASH (ORTHOFINDER.out)
    //GO_ENRICHMENT (BUILD_GO_HASH.out, input_)
}

workflow.onComplete {
	println ( workflow.success ? "\nDone! Open your report in your browser --> $params.outdir/report.html (if you added -with-report flag)\n" : "Hmmm .. something went wrong" )
}

