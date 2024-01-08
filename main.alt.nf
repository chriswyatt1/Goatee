params.input= "data/Example.csv"
params.outdir = "results"

//For CPU and Memory of each process: see conf/docker.config

log.info """\
 ===================================
	GOATEE v2.0

 ===================================
 input file                           : ${params.input}
 list of background species           : ${params.ensembl_dataset}
 out directory                        : ${params.outdir}
 """

//================================================================================
// Include modules
//================================================================================

include { GET_DATA } from './modules/getdata.nf'
include { ORTHOFINDER } from './modules/orthofinder.nf'
include { DOWNLOAD_NCBI } from './modules/download_ncbi.nf'
include { GFFREAD } from './modules/gffread.nf'
include { CAFE } from './modules/cafe.nf'
include { CHROMO_GO } from './modules/chromo_go.nf'

workflow {

	DOWNLOAD_NCBI ( input_type.ncbi )

	GFFREAD ( DOWNLOAD_NCBI.out.genome.mix(input_type.local) )

	ORTHOFINDER ( proteins_ch )

	CAFE ( ORTHOFINDER_2.out.no_ortho  , ORTHOFINDER_2.out.speciestree )	
	
	CAFE_GO ( CAFE.out.result , CAFE.out.N0_table , GO_ASSIGN.out.go_og.first() )

}

workflow.onComplete {
	println ( workflow.success ? "\nDone! Open your report in your browser --> $params.outdir/report.html (if you added -with-report flag)\n" : "Hmmm .. something went wrong" )
}

