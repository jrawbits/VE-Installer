# Author: Jeremy Raw

# VisionEval runtime initialization script
# Run once to install everything and build RunVisionEval.Rdata

require(utils)

# Put the current directory into ve.root
ve.root <- getwd()

# Put the library directory into ve.lib
# Note that ve.lib is already present and fully provisioned if we've unzipped the offline installer
# Current version (2019-03) actually uses a subdirectory for the R
# version
ve.lib.name <- file.path("ve-lib",paste(R.version[c("major","minor")],collapse="."))
ve.lib <- file.path(ve.root,ve.lib.name)

if ( ! dir.exists(ve.lib) ) {
  # Look in the build environment for ve-lib
  ve.lib.local <- normalizePath(file.path(ve.root,"..",ve.lib.name),winslash="/",mustWork=FALSE)
  if ( dir.exists(ve.lib.local) ) {
    ve.lib <- ve.lib.local # Use the build environment installed library
  } else {

    # Check for source environment
	ve.pkg.name <- "ve-pkg"
    ve.local  <- normalizePath(file.path(ve.root,"..",ve.pkg.name),winslash="/",mustWork=FALSE)
	ve.contrib.url <- contrib.url(ve.local,type="source")
    if ( ! dir.exists(ve.contrib.url) ) {
      message("Need accessible ve-lib or ve-pkg in the file system,")
      message("VisionEval packages are not available")
	  stop("Installation failed - check error and warning messages.")
    }

	# Check availability of source packages
	ve.contrib.url <- paste("file:",ve.contrib.url,sep="")
    VE.pkgs <- available.packages(contriburl=ve.contrib.url,type)[,"Package"]
    # Installation list is everything in the repository
    # Consequently: test and abort if visioneval isn't in it
    if ( ! "visioneval" %in% VE.pkgs[,Package] ) {
      message(paste("VisionEval not present in",ve.repos))
      message("VisionEval packages are not available")
	  stop("Installation failed - check error and warning messages.")
    }

	# Install to local environment
    dir.create(ve.lib,recursive=TRUE,showWarnings=FALSE)
    install.packages(
      VE.pkgs,
      lib=ve.lib,
      repos=ve.repos,
      quiet=TRUE
    )
  }
}

# Construct "RunVisionEval.Rdata" from the following objects
# Something to "double-click" in windows for a rapid happy start in RGui...

.First <- function() {
  .libPaths(ve.lib)
  if ( install.success <- require(visioneval) ) {
    setwd(ve.root)
    cat("Welcome to VisionEval!\n")
  } else {
	  cat("VisionEval is not present: please re-run the installation")
	}
  install.success
}

# Function starts the VEGUI
vegui <- function() {
  library("shiny")
  full_path <- file.path(ve.root,"VEGUI")
  owd <- setwd(full_path) 
  runApp('../VEGUI')
  setwd(owd)
}

# The following two functions run the command line model versions per the
# Getting Started document.  Optional "scenarios" argument, if TRUE, will
# run the scenarios version of the test models.
verpat <- function(scenarios=FALSE,baseyear=FALSE) {
  if ( ! scenarios ) {
    if ( ! baseyear ) {
      full_path <- file.path(ve.root,"models/VERPAT")
    } else {
      full_path <- file.path(ve.root,"models/BaseYearVERPAT")
    }
  } else {
    full_path <- file.path(ve.root,"models/VERPAT_Scenarios")
  }
  owd <- setwd(full_path)
  source("run_model.R")
  setwd(owd)
}

verspm <- function(scenarios=FALSE) {
  if ( ! scenarios ) {
    full_path <- file.path(ve.root,"models/VERSPM/Test1")
  } else {
    full_path <- file.path(ve.root,"models/VERSPM_Scenarios")
  }
  owd <- setwd(full_path)
  source("run_model.R")
  setwd(owd)
}

# Write objects to RunVisionEval.RData configuration file

install.success <- .First()
if ( install.success ) {
  save(file="VisionEval.RData"
    ,ve.root
    ,ve.lib
    ,.First
    ,vegui
    ,verpat
    ,verspm
  )
} else {
  stop("Installation failed - check error and warning messages.")
}
