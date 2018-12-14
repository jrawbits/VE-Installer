#!/bin/env Rscript

# Author: Jeremy Raw

# Build the external packages (e.g. namedCapture).
# Use dependencies/VE-dependencies.csv to specify "install".  You must manually
# check out the required packages (or otherwise retrieve them, e.g. from a .zip
# snapshot)

# Intent here is to pick up packages installed from github.  Those should be
# cloned as submodules, ideally in the VisionEval tree, not here in the
# installer.  If they are in VisionEval, we can just treat them as any other
# package though might want to skip tests.  Currenly only have one of those
# (namedCapture).

load("dependencies.RData")
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

require(tools) # for write_PACKAGES below

load("all-dependencies.RData") # relay list of dependencies

if ( nrow(pkgs.external) > 0 ) {
	cat("Building external packages (source)\n")

  if ( ! suppressWarnings(require(devtools)) ) {
      install.packages("devtools", repos=CRAN.mirror)
  }

	# Where to put the built results (these should exist after build-repository.R)
	built.path.src <- contrib.url(ve.repository, type="source")

	# External packages to build (possibly submodules)
	pkgs <- file.path(ve.install, pkgs.external[,"Path"], pkgs.external[,"Package"])

	pkg.dependencies <- as.character(pkgs.external[,"Package"])
	all.dependencies <- c( all.dependencies, pkg.dependencies)
	stated.dependencies <- c( stated.dependencies, pkg.dependencies )
	save(stated.dependencies, all.dependencies, file="all-dependencies.RData")

	cat("External Packages:\n")
	print(pkgs)

	# Build missing source packages
  num.built <- 0
	for ( pkg in pkgs ) {
		if ( ! moduleExists(pkg, built.path.src) ) {
			devtools::build(pkg, path=built.path.src)
            num.built <- num.built+1
		}
	}
    if ( num.built > 0) {
        write_PACKAGES(contrib.url(ve.repository, type="source"), type="source")
        cat(sprintf("Done building %d external packages.\n", num.built))
    } else {
        cat("No external packages requiring build.\n")
    }
} else {
    cat("No external packages configured.\n")
}

# The following for book-keeping
# May use it in the docker build to allow a "dependencies-only" image
write(paste(all.dependencies, collapse=" "),
      file=file.path(ve.repository, "dependencies.lst"))
