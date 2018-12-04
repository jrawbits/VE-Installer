# R version of setup sources (using file.copy)
# Advantage over using rsync is:
#  (a) don't need to add rsync to Msys (Git for Windows Bash) environment
#  (b) can find the folders using the VE-dependencies mechanism

load("dependencies.RData") # for the folders...
if (! check.VE.environment() ) stop("Run state-dependencies.R and make sure earlier steps have all been run.")

# Copy the runtime boilerplate

# Set the boilperplate folder
ve.boilerplate <- file.path(ve.install,"boilerplate")

# Get the boilerplate files
# boilerplate.lst just contains a list of the files to copy to runtime
# separated by whitespace (easiest just to do one file/directory name per line.
bp.file.list <- scan(file=file.path(ve.boilerplate,"boilerplate.lst"),quiet=TRUE,what=character())

# Copy the files
bp.files <- file.path(ve.boilerplate,bp.file.list)
if ( length(bp.files)>0 ) {
	invisible(file.copy(bp.files,ve.runtime,recursive=TRUE)) # currently there's nothing to recurse into)
}

# Get the VisionEval sources, if any are needed
# This will process the 'copy' items listed in dependencies/VE-dependencies.csv
copy.paths <- file.path(ve.root,pkgs.copy[,"Path"],pkgs.copy[,"Package"])
if ( length(copy.paths)>0 ) {
	cat(paste("Copying: ",copy.paths,"\n"))
	invisible(file.copy(copy.paths,ve.runtime,recursive=TRUE))
}
