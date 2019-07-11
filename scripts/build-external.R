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

# uncomment the following line on Windows if you just want the pre-compiled
# binaries otherwise, if RTools is installed the newer sources packages will be
# compiled.  You should allow compilation to happen if there is discrepancy in
# behavior between a Windows installation and a source (e.g. Linux/Docker)
# installation
options(install.packages.compile.from.source="never")

# Load required libraries (install as needed)

if ( ! suppressWarnings(require(git2r)) ) {
  install.packages("git2r", repos=CRAN.mirror, dependencies=NA, type=.Platform$pkgType)
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
  cat("Building external packages\n")

  if ( ! suppressWarnings(require(devtools)) ) {
    install.packages("devtools", repos=CRAN.mirror, type=.Platform$pkgType)
  }

  # Set build.type which controls what exactly gets built and how
  build.type <- .Platform$pkgType
  if ( build.type != "win.binary" ) build.type <- "source" # Skip mac build for now...

  # Where to put the built results (these should exist after build-repository.R)
  built.path.src <- contrib.url(ve.dependencies, type="source")
  if ( build.type == "win.binary" ) {
    built.path.binary <- contrib.url(ve.dependencies, type="win.binary")
  }

  # External packages to build
  pkg.names <- as.character(pkgs.external[,"Package"])

  # Update the dependencies report
  all.dependencies <- c( all.dependencies, pkg.names)
  stated.dependencies <- c( stated.dependencies, pkg.names )
  save(stated.dependencies, all.dependencies, file=ve.all.dependencies)

  # make sure the external package location exists
  if ( ! exists("ve.external") ) ve.external <- file.path(ve.output,"external")
  pkg.paths <- file.path(ve.external, pkg.names)

  # clone the github dependencies if their folder is not present
  # NOTE: if github package is damaged, you must delete its cloned
  # folder to re-clone...
  git.paths <- paste("https://github.com/",pkgs.external[,"Path"],sep="")
  for ( pkg in seq_along(pkg.paths) ) {
    if ( ! dir.exists(pkg.paths[pkg]) ) {
      cat("Cloning missing Github dependency:",git.paths[pkg],"into",pkg.paths[pkg],"\n")
      repo <- git2r::clone(git.paths[pkg],pkg.paths[pkg],progress=FALSE)
    }
  }

  # Build the packages (skipping ones that are already built)
  num.src <- 0
  num.built <- 0
  pkgs.installed <- installed.packages(lib.loc=ve.lib)[,"Package"]

  for ( pkg in seq_along(pkg.paths) ) {

    # Build or locate the source package
    if ( ! moduleExists(pkg.names[pkg],built.path.src) ) {
      src.pkg <- devtools::build(pkg.paths[pkg], path=built.path.src,vignettes=FALSE,manual=FALSE)
      num.src <- num.src + 1
    } else {
      src.pkg <- file.path( built.path.src, modulePath(pkg.names[pkg], built.path.src) )
    }

    # Determine if a build step is required
    package.built <- build.type != "win.binary" ||
                     (
                       moduleExists(pkg.names[pkg], built.path.binary) &&
                       ! newerThan( pkg.paths[pkg],
                                    file.path(built.path.binary,modulePath(pkg.names[pkg],built.path.binary)))
                     )
    package.installed <- package.built && pkg.names[pkg] %in% pkgs.installed

    if ( build.type == "win.binary" ) {
      # Windows: build binary package
      if ( ! package.built ) {
        cat("Building",pkg.names[pkg],"\n")
        built.package <- devtools::build(pkg.paths[pkg], path=built.path.binary, binary=TRUE)
        num.built <- num.built + 1
      } else {
        built.package <- file.path(built.path.binary, modulePath(pkg.names[pkg], built.path.binary))
      }
    } # No binary if source build
    if ( ! package.installed ) {
      cat("Installing ")
      if ( build.type == "win.binary" ) { # Windows: install from binary
        cat(built.package,"\n")
        install.packages(built.package, repos=NULL, lib=ve.lib)
      } else { # Not Windows: install from source package
        cat(src.pkg,"\n")
        install.packages(src.pkg, repos=NULL, lib=ve.lib, type="source")
      }
    }
  }
  if ( num.src > 0) {
      write_PACKAGES(built.path.src, type="source")
      cat(sprintf("Done building %d external source packages.\n", num.src))
  } else {
      cat("No external packages to build (source)\n")
  }
  if ( num.built > 0 ) {
    write_PACKAGES(built.path.binary, type="win.binary")
    cat(sprintf("Done building %d external binary packages\n",num.built))
  } else {
    cat("No external packages to build (binary)\n")
  } 
} else {
    cat("No external packages configured.\n")
}
