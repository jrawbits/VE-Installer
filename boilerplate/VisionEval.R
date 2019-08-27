# Author: Jeremy Raw

# VisionEval runtime initialization script
# Run once to install everything and build RunVisionEval.Rdata

require(utils)

# Check the R version (redundant on Windows, but saves having to
# have a separate VisionEval.R for Linux/Mac
this.R <- paste(R.version[c("major","minor")],collapse=".")
that.R <- scan("r.version",what=character())
if ( this.R != that.R ) {
  stop("Incorrect R version for this VisionEval installation: expecting R",that.R)
} else {
  cat("Loading VisionEval for R version",this.R,"\n")
}

# Put the current directory into ve.root
if ( (ve.root <- Sys.getenv("VE_ROOT",unset="" )) == "" ) {
  ve.root <- getwd()
} else {
  ve.root <- normalizePath(ve.root)
}

# Put the library directory into ve.lib
# Note that ve.lib is already present and fully provisioned if we've unzipped the offline installer
ve.lib.name <- "ve-lib"
ve.lib <- file.path(ve.root,ve.lib.name)

if ( ! dir.exists(ve.lib) ) {
  # Look in the build environment for ve-lib
  ve.lib.local <- normalizePath(file.path(ve.root,"..",ve.lib.name),winslash="/",mustWork=FALSE)
  if ( dir.exists(ve.lib.local) ) {
    ve.lib <- ve.lib.local # Use the build environment installed library
  } else {
    warning("Attempting source installation.")
    ve.pkg.name <- "ve-pkg"
    ve.pkg <- file.path(ve.root,ve.pkg.name)
    ve.contrib.url <- contrib.url(ve.pkg,type="source")
    if ( ! dir.exists(ve.contrib.url) ) {
      ve.pkg.local  <- normalizePath(file.path(ve.root,"..",ve.pkg.name),winslash="/",mustWork=FALSE)
      if ( dir.exists(ve.pkg.local) ) {
        ve.contrib.url <- contrib.url(ve.pkg.local,type="source")
      } else {
        message("Unable to locate ve-lib or ve-pkg in the file system,")
        message("VisionEval packages are not available")
        stop("Installation failed - check error and warning messages.")
      }
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
    dir.create(ve.lib,recursive=TRUE,showWarnings=FALSE) # under ve.root
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
  full.path <- file.path(ve.root,"VEGUI")
  owd <- setwd(full.path) 
  runApp('../VEGUI')
  setwd(owd)
}

# The following two functions run the command line model versions per the
# Getting Started document.  Optional "scenarios" argument, if TRUE, will
# run the scenarios version of the test models.
verpat <- function(scenarios=FALSE,baseyear=FALSE) {
  if ( ! scenarios ) {
    if ( ! baseyear ) {
      full.path <- file.path(ve.root,"models/VERPAT")
    } else {
      full.path <- file.path(ve.root,"models/BaseYearVERPAT")
    }
  } else {
    full.path <- file.path(ve.root,"models/VERPAT_Scenarios")
  }
  owd <- setwd(full.path)
  source("run_model.R")
  setwd(owd)
}

verspm <- function(scenarios=FALSE) {
  if ( ! scenarios ) {
    full.path <- file.path(ve.root,"models/VERSPM")
    test.dir <- file.path(full.path,"Test1") # Older structure for VERSPM
    if ( dir.exists(test.dir) ) full.path <- test.dir
  } else {
    full.path <- file.path(ve.root,"models/VERSPM_Scenarios")
  }
  owd <- setwd(full.path)
  source("run_model.R")
  setwd(owd)
}

if ( file.exists("tools/exporter.R") ) {
  if ( ! ve.lib %in% .libPaths() ) .libPaths(ve.lib)
  import::here(ve.export,.from="tools/exporter.R") # Tool to dump model outputs
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

