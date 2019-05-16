#!/bin/env Rscript

# Author: Jeremy Raw

# Build and optionally test the VE packages

# Very important to set up VE-config.yml and VE-components.yml correctly (see
# state-dependencies.R, and the example configurations in VE-Installer and in
# VisionEval-dev).

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

# Build tool dependencies
require(tools)
if ( ! suppressWarnings(require(devtools)) ) {
  install.packages("devtools", repos=CRAN.mirror)
}
if ( ! suppressWarnings(require(roxygen2)) ) {
  install.packages("roxygen2", repos=CRAN.mirror)
}

# Reach for ve.lib first when seeking packages used by the ones we're
# building
.libPaths( c(ve.lib, .libPaths()) ) # push runtime library onto path stack

# Where to put the built packages (may need to create the contrib.url)
build.type <- .Platform$pkgType
if ( build.type != "win.binary" ) build.type <- "source" # Skip mac build for now...
# To enable mac build, we also need to fix build-repository.R and install-velib.R
# in order to grab pre-built mac binaries if we can...

built.path.src <- contrib.url(ve.repository, type="source")
if ( ! dir.exists(built.path.src) ) dir.create( built.path.src, recursive=TRUE, showWarnings=FALSE )

# Set up contrib.url for binary build, if available for this architecture
if ( build.type != "source" ) {
  built.path.binary <- contrib.url(ve.repository, type=build.type)
  if ( ! dir.exists(built.path.binary) ) dir.create( built.path.binary, recursive=TRUE, showWarnings=FALSE )
} else {
  built.path.binary <- NULL
}

# Where to find the package sources (in the VisionEval repository)
ve.packages <- pkgs.db[pkgs.module,]

package.names <- ve.packages$Package
package.paths <- file.path(ve.packages[,"Root"], ve.packages[,"Path"], package.names)
# Want to assert that all of these have the same length!
# cat("Number of names:",length(package.names),"\n")
# cat("Number of paths:",length(package.paths),"\n")
# cat("Number of test paths:",length(package.testdir),"\n")
# cat("Number of test scripts:",length(test.scripts),"\n")

# Build the framework and modules as binary packages if the local system wants win.binary
# We do "build" for Windows so we can get the .zip package file into the binary pkg-repository
# On platforms other than Windows, simply installing will do the necessary build

# Locate modules to build in source repository (always build from source package)
built.path.source <- contrib.url(ve.repository,type="source") # VE source packages
source.modules <- unlist(sapply(package.names,
                  FUN=function(x) file.path(built.path.source,modulePath(x,built.path.source)),
                  USE.NAMES=FALSE))

# Copy test elements from components, if requested in configuration
if (ve.runtests) {
  # Copy any additional test folders to ve.test
  # Mostly for "Test_Data", but any set of stuff needed for all tests
  ve.test.files <- pkgs.db[pkgs.test,]
  if ( nrow(ve.test.files)>0 ) {
    test.paths <- file.path(ve.test.files$Root, ve.test.files$Path, ve.test.files$Package)
    need.copy <- newerThan(test.paths,file.path(ve.test,ve.test.files$Package))
    if ( need.copy ) {
      cat(paste(paste("Copying Test Item",test.paths,"to",ve.test,sep=" "),"\n"),sep="")
      invisible(file.copy(test.paths, ve.test, recursive=TRUE))
    } else {
      cat("Test data is up to date\n")
    }
  }
}

# Build binary packages on systems with supported .Platform$pkgType
# (whatever R supports, currently "win.binary" and "mac.binary.el-capitan")

# WARNING: The binary build will not rebuild packages once they have been built.
# To force a rebuild, delete the binary from ve-lib

num.src <- 0
num.bin <- 0
pkgs.installed <- installed.packages(lib.loc=ve.lib)[,"Package"]
for ( module in seq_along(package.names) ) {

  # Build missing our out-of-date source modules
  need.update <- newerThan( package.paths[module], source.modules[module] )
  if ( ! moduleExists(package.names[module], built.path.source) || need.update ) {
    if ( need.update ) cat("Updating package",package.names[module],"in",package.paths[module],"\n")
    source.modules[module] <- devtools::build(package.paths[module], path=built.path.src)
    num.src <- num.src + 1
  }

  # Build binary packages and conduct tests if needed
  build.dir <- file.path(ve.test,package.names[module])
  package.built <- moduleExists(package.names[module], built.path.binary) &&
                   dir.exists(build.dir) &&
                   ! newerThan( source.modules[module], file.path(built.path.binary,modulePath(package.names[module],built.path.binary)) )
  package.installed <- package.built && package.names[module] %in% pkgs.installed

  if ( ! package.built ) {
    cat("Copying module source",package.paths[module],"to build/test environment...\n")
    invisible(file.copy(package.paths[module],ve.test,recursive=TRUE))
    if ( ! dir.exists(build.dir) ) {
      stop("Failed to create build/test environment:",build.dir)
    }
  }

  if ( ve.runtests && ! package.built ) {
    cat("Running module tests for",package.names[module],"\n",sep="")
    # Run the module tests (prior to building anything)
    cat("Checking",build.dir,"\n")
    check.results <- devtools::check(build.dir,check_dir=build.dir,error_on="error")
    print(check.results)
    # devtools::check leaves the package loaded after its test installation to a temporary library
    # Therefore we need to explicitly detach it so we can install it properly later on
    detach(paste("package:",package.names[module],sep=""),character.only=TRUE,unload=TRUE)

    test.script <- file.path(build.dir,ve.packages$Test[module])
    cat("Executing tests from ",test.script,"\n")
    callr::rscript(script=test.script,wd=build.dir,libpath=.libPaths(),fail_on_status=FALSE)
    cat("Completed test script.\n")
  }

  if ( build.type != "source" ) {
    # This could handle mac binaries, but we need to adjust other
    # scripts to make sure mac dependencies are available
    if ( ! package.built ) {
      cat("building",package.names[module],"from",build.dir,"as",build.type,"\n")
      cat("building into",built.path.binary,"\n")
      built.package <- devtools::build(build.dir,path=built.path.binary,binary=TRUE)
      num.bin <- num.bin + 1
    } else {
      cat("Existing binary package:",package.names[module],ifelse(package.installed,"(Already Installed)",""),"\n")
      built.package <- file.path(built.path.binary, modulePath(package.names[module], built.path.binary))
    }
    if ( ! package.installed ) {
      cat("Installing built package:",built.package,"\n")
      install.packages(built.package, repos=NULL, lib=ve.lib, type=build.type) # so they will be available for later modules
    }
  } else { # build.type == "source"
    if ( ! package.installed ) {
      cat("Installing source package:",package.names[module],"\n")
      install.packages(package.names[module], repos=ve.repo.url, lib=ve.lib, type="source")
    } else {
      cat("Existing source package",package.names[module],"(Already Installed)\n")
    }
  }
}
if ( num.src > 0 ) {
  cat("Writing source PACKAGES file\n")
  write_PACKAGES(built.path.source, type="source")
} else {
  cat("No source packages needed to be built\n")
}
if ( num.bin > 0 ) {
  cat("Writing binary PACKAGES file\n")
  write_PACKAGES(built.path.binary, type=build.type)
} else {
  cat("No binary packages needed to be built.\n")
}

building <- paste( "building",ifelse(ve.runtests,", testing","") )
cat("Done ",building," and installing VisionEval packages.\n",sep="")
