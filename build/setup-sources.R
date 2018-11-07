# R version of setup sources (using file.copy)
# Advantage over using rsync is:
#  (a) don't need to add rsync to Msys (Git for Windows Bash) environment
#  (b) can find the folders using the VE-dependencies mechanism

load("dependencies.RData") # for the folders...
if (! check.VE.environment() ) stop("Run state-dependencies.R and make sure earlier steps have all been run.")

# Copy the runtime boilerplate
boilerplate <- file.path(ve.install,"boilerplate")
bp.files <- file.path(boilerplate,dir(boilerplate,all=TRUE,no..=TRUE))
if ( length(bp.files)>0 ) {
	invisible(file.copy(bp.files,ve.runtime)) # currently there's nothing to recurse into)
}

# Get the VisionEval sources, if any are needed
copy.paths <- file.path(ve.root,pkgs.copy[,"Path"],pkgs.copy[,"Package"])
if ( length(copy.paths)>0 ) {
	invisible(file.copy(copy.paths,ve.runtime,recursive=TRUE))
}
