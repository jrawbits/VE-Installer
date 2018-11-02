# R version of setup sources (using file.copy)
# Advantage over using rsync is:
#  (a) don't need to add rsync to Msys (Git for Windows Bash) environment
#  (b) can find the folders using the VE-dependencies mechanism

load("dependencies.RData") # for the folders...
if (! check.VE.environment() ) stop("Run state-dependencies.R and make sure earlier steps have all been run.")

copy.paths <- file.path(ve.root,pkgs.copy[,"Path"],pkgs.copy[,"Package"])
if ( length(copy.paths)>0 ) {
	dest.path <- file.path(ve.install,"runtime")
	file.copy(copy.paths,dest.path,recursive=TRUE)
}
