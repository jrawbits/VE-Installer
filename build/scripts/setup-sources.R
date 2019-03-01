#!/bin/env Rscript

# Author: Jeremy Raw

# Copies boilerplate (e.g. end user installation script) source tree files to
# the runtime - for things like the model data, run scripts and VEGUI app that
# are not in packages.

load("dependencies.RData")
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

# Copy the runtime boilerplate

# Set the boilperplate folder
ve.boilerplate <- file.path(ve.install, "boilerplate")

# Get the boilerplate files from boilerplate.lst
# boilerplate.lst just contains a list of the files to copy to runtime
# separated by whitespace (easiest just to do one file/directory name per line.

bp.file.list <- scan(file=file.path(ve.boilerplate, "boilerplate.lst"),
                     quiet=TRUE, what=character())

# Copy the boilerplate files, checking to see if what we expected was there

bp.files <- file.path(ve.boilerplate, bp.file.list)
if ( length(bp.files) > 0 ) {
  # currently there's nothing to recurse into)
  success <- suppressWarnings(file.copy(bp.files, ve.runtime, recursive=TRUE))
  if ( any( ! success ) ) {
    print(paste("Failed to copy boilerplate: ", basename(bp.files[!success])))
    cat("which may not be a problem (e.g. .Rprofile missing)\n")
    cat(".Rprofile is principally intended to house default ve.remote for online installer.\n")
    cat("If something else is missing, you should revisit boilerplate/boilerplate.lst\n")
  }
}

# Create the R version tag in the runtime folder
cat(paste(R.version[c("major","minor")],collapse="."),"\n",file=file.path(ve.runtime,"r.version"))

# Get the VisionEval sources, if any are needed
# This will process the 'copy' items listed in dependencies/VE-dependencies.csv

copy.paths <- file.path(pkgs.copy[,"Root"], pkgs.copy[,"Path"], pkgs.copy[,"Package"])
if ( length(copy.paths) > 0 ) {
  cat(paste("Copying: ", copy.paths, "\n"))
  invisible(file.copy(copy.paths, ve.runtime, recursive=TRUE))
}
