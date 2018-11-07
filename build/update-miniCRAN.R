# This script completes the miniCRAN build process

# Any external or visioneval packages that were built into the
# miniCRAN directories will be added to the PACKAGES files.

load("dependencies.RData") # for the folders...
if (! check.VE.environment() ) stop("Run state-dependencies.R and make sure earlier steps have all been run.")

src.contrib <- contrib.url(ve.miniCRAN,type="source")
bin.contrib <- contrib.url(ve.miniCRAN,type="win.binary")

require(tools)

num.source <- 0
if ( dir.exists(src.contrib) ) {
	num.source <- write_PACKAGES(src.contrib,type="source")
} else {
	cat("miniCRAN does not contain a source tree.\n")
	stop("Re-run build-miniCRAN.R")
}
if ( dir.exists(bin.contrib) ) {
	num.bin <- write_PACKAGES(bin.contrib,type="win.binary")
} else {
	cat("miniCRAN does not contain a win.binary tree.\n")
	stop("Re-run build-miniCRAN.R")
}

# cat("Available Source Packages:\n")
# print(available.packages(contriburl=paste("file:",src.contrib,sep="")))
# cat("============================\n")
# cat("Available Windows Binary Packages:\n")
# print(available.packages(contriburl=paste("file:",bin.contrib,sep="")))
# cat("============================\n")


