#!/bin/env Rscript

# Author: Jeremy Raw

# Copies boilerplate (e.g. end user installation script) source tree files to
# the runtime - for things like the model data, run scripts and VEGUI app that
# are not in packages.

this.R <- paste(R.version[c("major","minor")],collapse=".")
load(paste("dependencies",this.R,"RData",sep="."))
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

# Copy the runtime boilerplate

# Set the boilperplate folder
ve.boilerplate <- file.path(ve.install, "boilerplate")

# Get the boilerplate files from boilerplate.lst
# boilerplate.lst just contains a list of the files to copy to runtime separated by
# whitespace (easiest just to do one file/directory name per line.

# TODO: select a different boilerplate.lst depending on .Platform$pkg.type
# Use .sh files for "source" and .bat files for "win.binary"
build.type <- .Platform$pkgType
if ( build.type == "win.binary" ) {
  bp.file.list <- scan(file=file.path(ve.boilerplate, "boilerplate.lst"),
                       quiet=TRUE, what=character())
} else {
  bp.file.list <- scan(file=file.path(ve.boilerplate, "boilerplate.bash.lst"),
                       quiet=TRUE, what=character())
}  

# Copy the boilerplate files, checking to see if what we expected was there

bp.files <- file.path(ve.boilerplate, bp.file.list)
if ( length(bp.files) > 0 ) {
  # there may be nothing to recurse into...
  success <- suppressWarnings(file.copy(bp.files, ve.runtime, recursive=TRUE))
  if ( any( ! success ) ) {
    cat("WARNING!\n")
    print(paste("Failed to copy boilerplate: ", basename(bp.files[!success])))
    cat("which may not be a problem (e.g. .Rprofile missing)\n")
    cat(".Rprofile is principally intended to house default ve.remote for online installer.\n")
    cat("If something else is missing, you should revisit boilerplate/boilerplate.(bash.)lst\n")
  }
} else {
  stop("No boilerplate files defined to setup runtime!")
}

# Create the R version tag in the runtime folder
cat(this.R,"\n",sep="",file=file.path(ve.runtime,"r.version"))

# Get the VisionEval sources, if any are needed
# This will process the 'script' and 'model' items listed in dependencies/VE-dependencies.csv

pkgs.script <- pkgs.db[pkgs.script,c("Root","Path","Package")]
copy.paths <- file.path(pkgs.script$Root, pkgs.script$Path, pkgs.script$Package)
if ( length(copy.paths) > 0 ) {
  cat(paste("Copying Scripts: ", copy.paths),sep="\n")
  invisible(file.copy(copy.paths, ve.runtime, recursive=TRUE))
}

pkgs.model <- pkgs.db[pkgs.model,c("Root","Path","Package")]
copy.paths <- file.path(pkgs.model$Root, pkgs.model$Path, pkgs.model$Package)
if ( length(copy.paths) > 0 ) {
  cat(paste("Copying Models: ", copy.paths),sep="\n")
  model.path <- file.path(ve.runtime,"models")
  dir.create( model.path, recursive=TRUE, showWarnings=FALSE )
  invisible(file.copy(copy.paths, model.path, recursive=TRUE))
}
