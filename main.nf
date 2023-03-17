/*
 * Copyright (c) 2021
 */
 

 /*
 * Authors:
 * - Chris Wyatt <chris.wyatt@seqera.io>
 */

/*
 * Default pipeline parameters (on test data). They can be overriden on the command line eg.
 * given `params.genome` specify on the run command line `--outdir /path/to/outdir`.
 */

params.ensembl_repo="metazoa_mart"
params.ensembl_host='https://metazoa.ensembl.org'
params.ensembl_dataset="example.txt"
params.focal = "Branchiostoma_lanceolatum.BraLan2.pep.all.fa"
params.predownloaded_fasta= "./Background_species_folder/*"
params.predownloaded_gofiles= "./Background_gofiles_folder/*"
params.outdir = "results"
params.download= false


//For CPU and Memory of each process: see conf/docker.config

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
include { GO_ASSIGN } from './modules/go_assign.nf'

channel.fromPath(params.focal).set{ input_target_proteins_1 }
channel.fromPath(params.focal).set{ input_target_proteins_2 }

workflow {

	if (params.download){
		background_species = channel
			.fromPath(params.ensembl_dataset) 
			.splitText().map{it -> it.trim()}    
			.ifEmpty { error "Cannot find the dataset file: ${params.ensembl_dataset}" }

		input_host = channel
			.value(params.ensembl_host)
			.ifEmpty { error "Cannot find the host name: ${params.ensembl_host}" }

		input_repo = channel
			.value(params.ensembl_repo)
			.ifEmpty { error "Cannot find the repo name: ${params.ensembl_repo}" }

		GET_DATA ( input_repo, input_host, background_species )
		GET_DATA.out.fasta_files.mix(input_target_proteins_1).collect().view().set{ proteins_ch }
		GET_DATA.out.gene_ontology_files.set{ go_file_ch }

	}
	else{
		channel.fromPath(params.predownloaded_fasta).mix(input_target_proteins_1).collect().set{ proteins_ch }
		channel.fromPath(params.predownloaded_gofiles).collect().set{ go_file_ch }
	}
    ORTHOFINDER ( proteins_ch )
    GO_ASSIGN ( go_file_ch , ORTHOFINDER.out.orthologues, input_target_proteins_2)
}

workflow.onComplete {
	println ( workflow.success ? "\nDone! Open your report in your browser --> $params.outdir/report.html (if you added -with-report flag)\n" : "Hmmm .. something went wrong" )
}

