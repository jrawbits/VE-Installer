# Run with RScript to launch a VisionEval model
# See entrypoint.sh for setting up arguments
# $1 = the Model to run (ideally with full path)
# $2 = the Data directory to use for the model run

argv <- commandArgs(trailingOnly=TRUE)
if ( ! is.null(argv) && length(argv)==2 ) {
	setwd(argv[2])	# The DATA folder
	cat(paste(sep="","run_model.r: Running model '",argv[1],"' on data '",argv[2],"'\n"))
	source(argv[1]) # The MODEL to run
} else {
	cat(paste("run_model.r: Malformed Model '",argv[1],"' or Data '",argv[2],"'\n",sep=""))
}

