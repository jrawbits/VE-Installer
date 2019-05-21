#!/bin/env Rscript

# Author: Jeremy Raw

# Build binaries of any external packages (e.g. namedCapture)
# Use 'state-dependencies.R' to set up the required packages and VE directories.

# Intent here is to pick up packages installed from github.  Those should be cloned
# as submodules, ideally in the VisionEval tree, not here in the installer - if they
# are in VisionEval, we can just treat them as any other package though might want to
# skip tests.

default.config <- paste("logs/dependencies",paste(R.version[c("major","minor")],collapse="."),"RData",sep=".")
runtime.config <- Sys.getenv("VE_RUNTIME_CONFIG",default.config)
if ( ! file.exists(normalizePath(runtime.config,winslash="/")) ) {
  stop("Missing VE_RUNTIME_CONFIG",runtime.config,
       "\nRun state-dependencies.R to set up build environment")
}
load(runtime.config)
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

require(tools)

if ( ! suppressWarnings(require(devtools)) ) {
  install.packages("devtools", repos=CRAN.mirror)
}

pkgs.external <- pkgs.db$Package[pkgs.Github]
      
build.type <- .Platform$pkgType
if ( build.type != "win.binary" ) build.type <- "source" # Skip mac build for now...

if ( length(pkgs.external)> 0 ) {
  .libPaths( c(ve.lib, .libPaths()) ) # push runtime library onto path stack for dependencies
  pkgs.installed <- installed.packages(lib.loc=ve.lib)[,"Package"]

  built.path.source <- contrib.url(ve.dependencies, type="source")
  if ( build.type == "win.binary" ) {
		built.path.binary <- contrib.url(ve.dependencies, type="win.binary")
  }

  pkg.sources <- unlist(sapply(pkgs.external,
        FUN=function(x) file.path(built.path.source,modulePath(x,built.path.source)),
        USE.NAMES=FALSE))

  cat("Processing external packages:\n")
  cat(paste(pkg.sources,collapse="\n"),"\n",sep="")

  # External packages to build (possibly submodules)

  num.built <- 0
  for ( pkg in seq_along(pkgs.external) ) {
    if ( build.type == "win.binary" ) {
      package.built <- moduleExists(pkgs.external[pkg], built.path.binary) &&
                       ! newerThan( pkg.sources[pkg], file.path(built.path.binary,modulePath(pkgs.external[pkg],built.path.binary)))
    } else {
      package.built <- TRUE
    }
    package.installed <- package.built && pkgs.external[pkg] %in% pkgs.installed

    built.package <- NULL
    if ( build.type == "win.binary" ) {
      if ( ! package.built ) {
        cat("Building",pkgs.external[pkg],"\n")
        built.package <- devtools::build(file.path(ve.external, pkgs.external[pkg]), path=built.path.binary, binary=TRUE)
      } else {
        built.package <- file.path(built.path.binary, modulePath(pkgs.external[pkg], built.path.binary))
      }
      num.built <- num.built + 1
    }
    if ( ! package.installed ) {
      cat("Installing")
      if ( build.type == "win.binary" ) {
        cat(built.package,"\n")
        install.packages(built.package, repos=NULL, lib=ve.lib) # so they will be available for later modules
      } else {
        cat(pkg.sources[pkg],"\n")
        install.packages(pkg.sources[pkg], repos=NULL, lib=ve.lib, type="source")
      }
    }
  }
  if ( num.built > 0 ) write_PACKAGES(built.path.binary, type="win.binary")
  cat("Done building external packages\n")
} else {
  cat("No external packages to build (binary)\n")
}
