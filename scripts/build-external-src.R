#!/bin/env Rscript

# Author: Jeremy Raw

# Build any Github packages (e.g. namedCapture).

# Load runtime configuration
default.config <- paste("logs/dependencies",paste(R.version[c("major","minor")],collapse="."),"RData",sep=".")
ve.runtime.config <- Sys.getenv("VE_RUNTIME_CONFIG",default.config)
if ( ! file.exists(normalizePath(ve.runtime.config,winslash="/")) ) {
  stop("Missing VE_RUNTIME_CONFIG",ve.runtime.config,
       "\nRun state-dependencies.R to set up build environment")
}
load(ve.runtime.config)
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

# Load required libraries (install as needed)

if ( ! suppressWarnings(require(git2r)) ) {
  install.packages("git2r", repos=CRAN.mirror, dependencies=NA)
}
require(tools) # for write_PACKAGES below

# relay dependencies
load(ve.all.dependencies) # use all.dependencies
if ( ! exists("all.dependencies") ) {
  stop("Run state-dependencies.R to set up build environment")
}

pkgs.external <- pkgs.db[pkgs.Github,]

# Need to change this so we clone the repository into "ve.external"
# Update Locations to require/identify ve.external (defaults to
# "external" in the output folder).
# Use git2r package, "clone" function, but only if cloned folder
# does not exist.
# Once we've retrieved the package (and have its path) we can just do
# the build as usual

if ( nrow(pkgs.external) > 0 ) {
  cat("Building external packages (source)\n")

  if ( ! suppressWarnings(require(devtools)) ) {
    install.packages("devtools", repos=CRAN.mirror)
  }

  # Update the dependencies report
  pkg.dependencies <- as.character(pkgs.external[,"Package"])
  all.dependencies <- c( all.dependencies, pkg.dependencies)
  stated.dependencies <- c( stated.dependencies, pkg.dependencies )
  save(stated.dependencies, all.dependencies, file=ve.all.dependencies)

  # make sure the external locatione exists
  if ( ! exists("ve.external") ) ve.external <- file.path(ve.output,"external")

  # External packages to build
  pkgs <- file.path(ve.external, pkgs.external[,"Package"])
	paths <- paste("https://github.com/",pkgs.external[,"Path"],sep="")

  cat("External Packages:\n")
  print(paste(paths,pkgs,sep=' AS '))

  # check that there's a folder for each Github dependency
  for ( i in seq_along(pkgs) ) {
		if ( ! dir.exists(pkgs[i]) ) {
			cat("Cloning missing Github dependency:",paths[i],"into",pkgs[i],"\n")
			repo <- git2r::clone(paths[i],pkgs[i],progress=FALSE)
		}
  }

  # Where to put the built results (these should exist after build-repository.R)
  built.path.src <- contrib.url(ve.dependencies, type="source")

  # Build missing source packages
  num.built <- 0
  for ( pkg in pkgs ) {
    if ( ! moduleExists(pkg, built.path.src) ) {
      devtools::build(pkg, path=built.path.src,vignettes=FALSE,manual=FALSE)
            num.built <- num.built+1
    }
  }
  if ( num.built > 0) {
      write_PACKAGES(built.path.src, type="source")
      cat(sprintf("Done building %d external packages.\n", num.built))
  } else {
      cat("No external packages requiring build.\n")
  }
} else {
    cat("No external packages configured.\n")
}

# The following for book-keeping
# May use it in the docker build to allow a "dependencies-only" image
write(paste(all.dependencies, collapse=" "), file=ve.all.dependencies)
