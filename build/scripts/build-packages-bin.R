#!/bin/env Rscript

# Author: Jeremy Raw

# Build the binary VE packages

# Very important to set up VE-dependencies.csv correctly (see
# state-dependencies.R) If there is a dependency order among the VE modules,
# they must be listed in VE-dependencies.csv in the order in which they will be
# built

# We're not going to rebuild from source if the binary is outdated and
# compilation is required 12/18/2018: I think this line is obsolete (only useful
# for desynchronized CRAN packages)

# options(install.packages.compile.from.source="never")

load("dependencies.RData")
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

require(tools)
if ( ! suppressWarnings(require(devtools)) ) {
  install.packages("devtools", repos=CRAN.mirror)
}

# Reach for ve.lib first.
# Could use this hack to squeeze out local libraries, but we still need devtools...
# https://stackoverflow.com/questions/36873307/how-to-change-and-remove-default-library-location
#   old.lib.loc <- get(".lib.loc", envir=environment(.libPaths))
#   assign(".lib.loc", c(ve.lib, .Library), envir=environment(.libPaths))
# The following appears to suffice

.libPaths( c(ve.lib, .libPaths()) ) # push runtime library onto path stack

# NOTE: developers are discouraged from putting any/too many depedencies into their
# development environment, especially when adding dependencies - those should always
# find their way (first) into the miniCRAN (or be installed into ve.lib)
# The best way to do this is to point your local R_LIBS_USER to a fresh directory
# when you start working with VisionEval (e.g. via an .Rprofile in the build
# directory) and then let these scripts install their own dependencies from
# the CRAN.mirror (you can set in .Rprofile, defaulted in state-dependencies.R)

# Where to find the package sources (in the VisionEval repository)

package.paths <- file.path(pkgs.visioneval[,"Root"], pkgs.visioneval[,"Path"], pkgs.visioneval[,"Package"])

# Where to put the built results (these should exist after build-repository.R)

built.path.binary <- contrib.url(ve.repository, type="win.binary")

# Build the framework and modules as binary packages if the local system wants win.binary
# We do "build" for Windows so we can get the .zip package file into the binary pkg-repository
# On platforms other than Windows, simply installing will do the necessary build
# The Windows binary build will not rebuild packages once they have been built
# To force a rebuild, delete the windows binary from ve-lib

build.type <- .Platform$pkgType
if ( build.type == "win.binary" ) {
	for ( module in package.paths ) {
		if ( ! moduleExists(module, built.path.binary) ) {
			built.package <- devtools::build(module, path=built.path.binary, binary=TRUE)
		} else {
			built.package <- file.path(built.path.binary, modulePath(module, built.path.binary))
		}
		install.packages(built.package, repos=NULL, lib=ve.lib) # so they will be available for later modules
	}
	write_PACKAGES(built.path.binary, type="win.binary")
} else {
	# install source package in whatever binary form works for the local environment
	for ( module in package.paths ) {
		install.packages(module, repos=NULL, lib=ve.lib, type="source")
	}
}
cat("Done installing VisionEval binary packages.\n")
