#!/bin/env Rscript

# Author: Jeremy Raw

# Merges dependencies and VE packages into a single repository

load("dependencies.RData")
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

require(tools)

# Copy the cached package repository into ve.pkgs
src.package <- contrib.url(ve.repository, type="source")
src.deps <- contrib.url(ve.dependencies, type="source")
src.all <- contrib.url(ve.pkgs, type="source")
if ( ! dir.exists(src.all) ) dir.create( src.all, recursive=TRUE, showWarnings=FALSE )

cat(src.deps,"\n")
cat(src.all,"\n")

# TODO: Use the "available.packages" function to only copy files that
# area not already in ve-pkgs.

cat("Copying",src.package,"\n")
dir(src.package)
invisible(file.copy(file.path(src.package,dir(src.package)), src.all, overwrite=TRUE))
cat("\nCopying",src.deps,"\n")
dir(src.deps)
invisible(file.copy(file.path(src.deps,dir(src.deps)), src.all, overwrite=TRUE))
cat("\nWriting PACKAGES in",src.all,"\n")
write_PACKAGES(src.all, type="source")
