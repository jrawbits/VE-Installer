#!/bin/env Rscript

# Author: Jeremy Raw

# Merges dependencies and VE packages into a single source repository

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

# Relay dependency list

load(ve.all.dependencies) # use all.dependencies
if ( ! exists("all.dependencies") ) {
  stop("Run state-dependencies.R to set up build environment")
}

# Load required Library

require(tools)

# Prepare package names and output repository contriburl

ve.pkgnames <- pkgs.db[pkgs.module,]$Package
src.contrib <- contrib.url(ve.pkgs, type="source")
if ( ! dir.exists( src.contrib ) ) dir.create(src.contrib, recursive=TRUE, showWarnings=FALSE)

# Save out lists of dependencies and packages
cat(file=file.path(ve.pkgs,"dependencies.lst"),paste(all.dependencies,collapse=" "),"\n")
cat(file=file.path(ve.pkgs,"visioneval.lst"),paste(ve.pkgnames,collapse=" "),"\n")

# Start work...

cat("Preparing source distribution repository\n")
if ( ! dir.exists(src.contrib) || ! file.exists(file.path(src.contrib,"PACKAGES")) ) {
  cat("Building fresh source distribution repository\n")
  for ( repo in c(ve.dependencies,ve.repository) ) {
    contriburl <- contrib.url(repo,type="source")
    pkgs <- dir(contriburl,full.names=TRUE)
    invisible( file.copy( pkgs, src.contrib, recursive=TRUE, overwrite=TRUE ) )
  }
  write_PACKAGES(src.contrib, type="source")
} else {
  cat("Checking if required packages are present\n")
  if ( any( ! file.exists(file.path(src.contrib,dir(src.contrib,pattern="PACKAGES.*"))) ) ) {
    # Probably no way for packages to sneak in unannounced, but just in case...
    write_PACKAGES(src.contrib, type="source")
  }
  ap <- available.packages(repos=paste("file:", ve.pkgs, sep=""), type="source")
  missing.deps <- setdiff( all.dependencies, ap[,"Package"])
  if ( length(missing.deps) > 0 ) {
    cat("Adding missing dependencies to source distribution repository\n")
    deps.dir <- contrib.url(ve.dependencies,type="source")
    print(missing.deps)
    missing.deps <- file.path( deps.dir,modulePath( missing.deps, deps.dir ) )
    print(missing.deps)
    file.copy( missing.deps, src.contrib, recursive=TRUE, overwrite=TRUE )
  } else {
    cat("Source distribution repository dependencies are up to date\n")
  }
  missing.pkgs <- setdiff( ve.pkgnames, ap[,"Package"])
  if ( length(missing.pkgs) > 0 ) {
    cat("Adding missing VE packages to source distribution repository\n")
    pkgs.dir <- contrib.url(ve.repository,type="source")
    print(missing.pkgs)
    missing.pkgs <- file.path( pkgs.dir,modulePath( missing.pkgs, pkgs.dir ) )
    print(missing.pkgs)
    file.copy( missing.pkgs, src.contrib, recursive=TRUE, overwrite=TRUE )
  } else {
    cat("Source distribution repository VE packages are up to date\n")
  }
  if ( length(missing.deps)>0 || length(missing.pkgs)>0 ) write_PACKAGES(src.contrib, type="source")
}
