#!/bin/env Rscript

# Author: Jeremy Raw

# Build the VE source packages

# Very important to set up VE-dependencies.csv correctly (see
# state-dependencies.R) If there is a dependency order among the VE modules,
# they must be listed in VE-dependencies.csv in the order in which they will be
# built

load("dependencies.RData")
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

require(tools)
if ( ! suppressWarnings(require(devtools)) ) {
	install.packages("devtools", repos=CRAN.mirror)
}
if ( ! suppressWarnings(require(knitr)) ) {
	install.packages("knitr", repos=CRAN.mirror)
}

# Where to find the package sources (in the VisionEval repository)

ve.packages <- pkgs.visioneval[,"Package"]
package.paths <- file.path(ve.root, pkgs.visioneval[,"Path"], ve.packages)

# Where to put the built results (these should exist after build-miniCRAN.R)

built.path.src <- contrib.url(ve.repository, type="source")

num.built <- 0
for ( module in package.paths ) {
	if ( ! moduleExists(module, built.path.src) ) {
		devtools::build(module, path=built.path.src)
        num.built <- num.built+1
	}
}
if ( num.built > 0) {
    write_PACKAGES(contrib.url(ve.repository, type="source"), type="source")
    cat(sprintf("Done building %d VisionEval packages.\n", num.built))
} else {
    cat("No VisionEval packages requiring build.\n")
}
write(paste(as.character(ve.packages), collapse=" "),
      file=file.path(ve.repository, "visioneval.lst"))

