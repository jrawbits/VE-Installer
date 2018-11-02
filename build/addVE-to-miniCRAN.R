# This script completes the miniCRAN build process
# Local packages (framework, modules, external) are loaded

# Remember to have path.miniCRAN into .RProfile or otherwise have it set when running this script
load("dependencies.RData") # for the folders...
if (! check.VE.environment() ) stop("Run state-dependencies.R and make sure earlier steps have all been run.")

dir.src <- file.path(ve.built,"src")
dir.bin <- file.path(ve.built,"bin")

# Check that the required packages have already been built
if ( !file.exists(dir.src) || !file.exists(dir.bin) ) {
	cat("Need to build packages and externals prior to running this script.\n")
	stop("Build step out of sequence")
}

miniCRAN::addLocalPackage(dir(dir.src),pkgPath=dir.src,path=path.miniCRAN,type="source")

# we explicitly recover the names in the src directory as there may be externals like namedCapture there
ve.pkgs <- sapply(strsplit(dir(dir.src),"_"),"[",1)
if ( file.exists(dir.bin) && length(dir(dir.bin))>0 ) {
    miniCRAN::addLocalPackage(dir(dir.bin),pkgPath=dir.bin,path=path.miniCRAN,type="win.binary")
} else {
	cat("Failed to add binary packages to miniCRAN as they seem not to exist\n")
	cat("This message is expected on source-based systems (Linux, MacOS)\n")
}

# Also need to install those to ve.lib
# This will install either source or binary depending on the developers R environment
# No facility for cross-platform builds is currently available
install.packages(ve.pkgs,repos=repo.miniCRAN(),lib=ve.lib,dependencies=TRUE)
