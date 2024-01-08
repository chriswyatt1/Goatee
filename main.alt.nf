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
 
include { DOWNLOAD_NCBI } from './modules/download_ncbi.nf'
include { GFFREAD } from './modules/gffread.nf'
include { ORTHOFINDER } from './modules/orthofinder.nf'
include { CAFE } from './modules/cafe.nf'
 
workflow {
 
	DOWNLOAD_NCBI ( params.input )
 
	GFFREAD ( DOWNLOAD_NCBI.out.genome )
 
	ORTHOFINDER ( GFFREAD.out.proteins )
 
	CAFE ( ORTHOFINDER.out.no_ortho  , ORTHOFINDER.out.speciestree )
 
}
 
workflow.onComplete {
	println ( workflow.success ? "\nDone! Open your report in your browser --> $params.outdir/report.html (if you added -with-report flag)\n" : "Hmmm .. something went wrong" )
}
