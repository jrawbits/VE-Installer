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
  install.packages("devtools", repos=CRAN.mirror, type=.Platform$pkgType )
}
if ( ! suppressWarnings(require(roxygen2)) ) {
  install.packages("roxygen2", repos=CRAN.mirror, type=.Platform$pkgType )
}
if ( ! suppressWarnings(require(rcmdcheck)) ) {
  install.packages("rcmdcheck", repos=CRAN.mirror, type=.Platform$pkgType )
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

debug <- as.integer(Sys.getenv("VE_DEBUG_LEVEL",0)) # 0: no debug, 1: lightweight, 2: full details
if ( is.na(debug) ) debug <- 0 # in case VE_INST_DEBUG

# Locate modules to build in source repository (always build from source package)
source.modules <- unlist(sapply(package.names,
                  FUN=function(x) file.path(built.path.src,modulePath(x,built.path.src))))
if ( debug>1 ) {
  print(source.modules)
  cat("Source modules identified:\n")
  print(paste(package.names,source.modules[package.names],file.exists(source.modules[package.names]),sep=":"))
}

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

# Build missing or out-of-date source modules
for ( module in seq_along(package.names) ) {
  src.module <- source.modules[package.names[module]]

  # Step one: picky message to see if we're updating or creating the module fressh
  need.update <- newerThan( package.paths[module], src.module, quiet=(debug<2) )
  if ( ! (me <- moduleExists(package.names[module], built.path.src)) || need.update ) {
    if ( me ) { # module exists
      cat("Updating package",package.names[module],"from",package.paths[module],"(Exists: ",me,")\n")
    } else {
      cat("Creating package",package.names[module],"from",package.paths[module],"(Exists:",me,")\n")
    }
  }

  # Step two: Determine package status (built, installed)
  build.dir <- file.path(ve.test,package.names[module])
  if ( debug ) cat( build.dir,"exists:",dir.exists(build.dir),"\n")
  if ( build.type != 'source' ) {
    # On Windows, the package is built if:
    #   a. Binary package is present, and
    #   b. package source is not newer than ve.test copy of source
    #   c. Binary package is newer than source package
    nt <- de <- me <- as.logical(NA)
    package.built <- (me <- moduleExists(package.names[module], built.path.binary)) &&
                     (de <- ( dir.exists(build.dir) && ! newerThan(package.paths[module],build.dir,quiet=(!debug)) )) &&
                     (nt <- ! newerThan( quiet=(debug<2),
                              src.module,
                              file.path(built.path.binary,
                                        modulePath(package.names[module],built.path.binary))) )
    if ( debug && ! package.built ) {
      cat("Status of unbuilt",package.names[module],"\n")
      cat("Module",me," ","Dir",de," ","Newer",nt," ","Inst",(package.names[module] %in% pkgs.installed),"\n")
    }
  } else {
    # If Source build, the package is "built" if:
    #   a. package source is not newer than ve.test copy of source
    package.built <- dir.exists(build.dir) && ! newerThan( package.paths[module], build.dir )
  }
  if ( ! package.built ) cat(package.names[module],"is NOT built\n")

  # Package is installed if it is built and is an available installed package
  package.installed <- package.built && package.names[module] %in% pkgs.installed
  if ( ! package.installed ) cat(package.names[module],"is NOT installed\n")

  # Step 3: If package is not built, copy package source to ve.test
  # On Windows: ve.test copy is used to build binary package and to run tests
  # For Source build: ve.test copy is always created but only used if running tests
  if ( ! package.built ) {
    if ( debug>1 ) {
      # Dump list of package source files if debugging
      pkg.files <- file.path(package.paths[module],dir(package.paths[module],recursive=TRUE))
      cat(paste("Copying",pkg.files,"to",build.dir,"\n",sep=" "),sep="")
    } else {
      cat("Copying module source",package.paths[module],"to build/test environment...\n")
    }
    if ( dir.exists(build.dir) ) unlink(build.dir,recursive=TRUE) # Get rid of the build directory (in case anything was removed)
    pkg.files <- file.path(package.paths[module],dir(package.paths[module],recursive=TRUE,all.files=FALSE)) # not hidden files
    invisible(file.copy(from=pkg.files,to=build.dir,recursive=TRUE, copy.date=TRUE))
    if ( ! dir.exists(build.dir) ) {
      stop("Failed to create build/test environment:",build.dir)
    }
    if ( newerThan(package.paths[module],build.dir,quiet=(!debug)) ) {
      stop("After copying, build/test environment is still older than package.paths")
    }
  }

  # Step 4: Check the module in order to rebuild the /data directory in build.dir
  if ( ! package.built ) {
    cat("Checking and pre-processing ",package.names[module],"\n",sep="")
    # Run the module tests (prior to building anything)
    check.results <- devtools::check(build.dir,check_dir=build.dir,error_on="error")
    print(check.results)
    # devtools::check leaves the package loaded after its test installation to a temporary library
    # Therefore we need to explicitly detach it so we can install it properly later on
    detach(paste("package:",package.names[module],sep=""),character.only=TRUE,unload=TRUE)

    # Then get rid of the temporary (and possibly obsolete) source package that is left behind
    tmp.build <- modulePath(package.names[module],build.dir)
    if ( file.exists(tmp.build) ) unlink(tmp.build)

    # Run the tests on build.dir if requested
    if ( ve.runtests ) {
      test.script <- file.path(build.dir,ve.packages$Test[module])
      cat("Executing tests from ",test.script,"\n")
      callr::rscript(script=test.script,wd=build.dir,libpath=.libPaths(),fail_on_status=FALSE)
      cat("Completed test script.\n")
    }
  }

  # If not built, rebuild the source module from build.dir
  if ( ! package.built ) {
    cat("building",package.names[module],"from",build.dir,"as source\n")
    src.module <- devtools::build(build.dir, path=built.path.src)
    num.src <- num.src + 1
  }

  # Step 6: Build the binary package (Windows only) and install the package
  if ( build.type != "source" ) {
    # Windows build and install works a little differently from source
    if ( ! package.built ) {
      # Rebuild the binary package from the ve.test folder
      # We do this on Windows (rather than building from the source package) because
      # we want to use devtools::build, but a bug in devtools prior to R 3.5.3 or so
      # prevents devtools:build from correctly building from a source package (it
      # requires an unpacked source directory, which we have in build.dir)
      cat("building",package.names[module],"from",build.dir,"as",build.type,"\n")
      cat("building into",built.path.binary,"\n")
      built.package <- devtools::build(build.dir,path=built.path.binary,binary=TRUE)
      num.bin <- num.bin + 1
    } else {
      cat("Existing binary package:",package.names[module],ifelse(package.installed,"(Already Installed)",""),"\n")
      built.package <- file.path(built.path.binary, modulePath(package.names[module], built.path.binary))
    }
    if ( ! package.installed ) {
      # On Windows, install from the binary package
      cat("Installing built package:",built.package,"\n")
      install.packages(built.package, repos=NULL, lib=ve.lib, type=build.type) # so they will be available for later modules
    }
  } else { # build.type == "source"
    # For source build, just do installation from source package (no binary package created)
    if ( ! package.installed ) {
      cat("Installing source package:",src.module,"\n")
      install.packages(src.module, repos=NULL, lib=ve.lib, type="source")
    } else {
      cat("Existing source package",package.names[module],"(Already Installed)\n")
    }
  }
}

# Update the repository PACKAGES files (source and binary) if we rebuilt any
# of the packages.
warnings()
if ( num.src > 0 ) {
  cat("Writing source PACKAGES file\n")
  write_PACKAGES(built.path.src, type="source")
} else {
  cat("No source packages needed to be built\n")
}
if ( build.type != "source" ) {
  if ( num.bin > 0 ) {
    cat("Writing binary PACKAGES file\n")
    write_PACKAGES(built.path.binary, type=build.type)
  } else {
    cat("No binary packages needed to be built.\n")
  }
}

# Completion message, reporting what happened in this step
building <- paste( "building",ifelse(ve.runtests,", testing","") )
cat("Done ",building," and installing VisionEval packages.\n",sep="")
