#!/bin/env Rscript

# Author: Jeremy Raw

# This script just sets up all the VisionEval reference points
# (directories and key files, web locations, etc.) and makes
# them available to other scripts such as build-repository.R

# Required input:  VE-dependencies.csv in ve.install/dependencies
# Instructions on creating the dependencies file are in the ReadMe.md
# at that location.

# Pick the CRAN mirror to use for retrieving dependency packages
# may override in .Rprofile

if ( ! exists("CRAN.mirror") || is.na(CRAN.mirror) ) {
  CRAN.mirror <- "https://cran.rstudio.org"
}

# Can override ve.install in .Rprofile (default presumes the working
# directory is the "build" subdirectory of the ve.install root)
if ( ! exists("ve.install") || is.na(ve.install) || ! file.exists(ve.install) ) {
  # The following includes a hack to fix a common path problem if you are
  # developing on Windows in a subfolder of "My Documents"
  ve.install <- sub("My Documents", "Documents",
                    normalizePath(file.path(getwd(), "..")))
}
ve.dependencies <- file.path(ve.install, "dependencies")
source(file.path(ve.dependencies, "VE-config.R"))

if ( ! exists("ve.output") || is.na(ve.output) ) {
  ve.output <- file.path(ve.install,
                         paste("installer", format(Sys.time(), "%y%m%d"), sep="_"))
}
ve.output <- gsub("\\\\", "/", ve.output)
ve.install <- gsub("\\\\", "/", ve.install)

# Convey key file locations to the 'make' environment
make.target <- file("ve-output.make")
ve.platform <- .Platform$OS.type # Used to better identify binary installer type
ve.r.version <- "3.5.1"  # Eventually make this configurable so we can build to other versions
writeLines(paste(c("VE_OUTPUT", "VE_ROOT", "VE_INSTALLER", "VE_PLATFORM", "VE_R_VERSION"),
                 c(ve.output, ve.root, ve.install, ve.platform, ve.r.version),
                 sep="="),
           make.target)
close(make.target)

ve.runtime <- file.path(ve.output, "runtime")
ve.lib <- file.path(ve.output, "ve-lib")
ve.repository <- file.path(ve.output, "pkg-repository")
ve.repo.url <- paste("file:", ve.repository, sep="")

# Create the basic output tree
dir.create(ve.runtime, recursive=TRUE, showWarnings=FALSE)
dir.create(ve.lib, recursive=TRUE, showWarnings=FALSE)
dir.create(ve.repository, recursive=TRUE, showWarnings=FALSE)

# Produce the various package lists for retrieval
pkgs.db <- read.csv(file.path(ve.dependencies, "VE-dependencies.csv"))
getPackageList <- function(type="", path=FALSE) {
  # Return a subset (or everything) from the pkgs.db dependency list
  # which was loaded from "dependencies/dependencies.csv"
  #
  # Args:
  #   type: The type identifying a subset of pkgs.db to seek
  #         (empty string: all)
  #   path: If TRUE, then also return the "Path" element of pkgs.db
  #         for the selected subset (e.g. for copying sources)
  #
  # Returns: if path is FALSE, a vector of package names to retrieve
  #          from the "type" of public repository (CRAN, BioConductor,
  #          other CRAN-like source). If path is TRUE, a data.frame of
  #          two columns, the "Package" names and the "Path" (relative
  #          to the standard root used for that type of package).
  #          See the use of the pkgs.* variables in later scripts.
  if ( ! path ) {
    as.character(
      if ( type > "") {
        pkgs.db[which(pkgs.db["Type"]==type),"Package"]
      } else {
        pkgs.db[,"Package"]
      }
    )
  } else {
    pkgs.db[which(pkgs.db["Type"]==type), c("Package", "Path")]
  }
}
pkgs.all        <- getPackageList()
pkgs.CRAN       <- getPackageList("CRAN")
pkgs.BioC       <- getPackageList("BioConductor")
pkgs.external   <- getPackageList("install", path=TRUE)
pkgs.visioneval <- getPackageList("visioneval", path=TRUE)
pkgs.copy       <- getPackageList("copy", path=TRUE)

# NOTE: there is an order dependency for building/checking modules
# Generally, it is important to use the list in the order presented below
# Check with the current VisionEval source tree for updates
# framework <- "visioneval"
# modules <- c(
#    "VE2001NHTS"
#   , "VESyntheticFirms"
#   , "VESimHouseholds"
#   , "VELandUse"
#   , "VETransportSupply"
#   , "VETransportSupplyUse"
#   , "VEHouseholdTravel"
#   , "VEHouseholdVehicles"
#   , "VEPowertrainsAndFuels"
#   , "VETravelPerformance"
#   , "VEReports"
#   )
 
# Helper function for other scripts, to verify situational awareness

checkVEEnvironment <- function() {
  # Check for situational awareness, and report if we are lost
  # Returns 0 or 1
  if ( ! exists("ve.root") || is.na(ve.root) || !file.exists(ve.root) ) {
    cat("Missing ve.root - set in .RProfile to root of VE repository\n")
    return(FALSE)
  } else if ( ! exists("ve.install") || is.na(ve.install) || ! file.exists(ve.install) ) {
    cat("Missing ve.install - set in .RProfile to root of installer tree\n")
    return(FALSE)
  } else if ( ! exists("ve.lib") || is.na(ve.lib) ) {
    cat("Missing ve.lib definition; run state-dependencies.R\n")
    return(FALSE)
  } else if ( ! exists("ve.repository") || is.na(ve.repository) ) {
    cat("Missing ve.repository definition; run state-dependencies.R\n")
    return(FALSE)
  }
  TRUE
}

.First <- function() {
  # If you try to load dependencies.RData interactively in an incomplete
  # environment, you will be busted (e.g. by checking it accidentally into
  # your repository and then checking out somewhere else without setting up
  # the environment, or if you damage the environment by changing the name
  # of the VisionEval source tree root).
  if ( ! exists("checkVEEnvironment") || ! checkVEEnvironment() ) {
    stop("Please set ve.root VE-config.R, then source('state-depedencies.R')")
  }
}

# The following two helpers extract modules from built packages
# Used in the scripts to detect whether a module has been built yet.
modulePath <- function( module, path ) {
  # determine which module in a vector of names is present in the
  # current directory
  #
  # Args:
  #   module: a character vector of module names to look for
  #   path: a file system path to look for the modules
  #
  # Returns:
  #   A character vector of the file system names (include version
  #   number strings) for the corresponding packages in module,
  #   if any
  mods <- dir(path)
  result <- mods[grep(paste("^", basename(module), "_", sep=""), mods)]
}

moduleExists <- function( module, path ) {
  # determine if modulePath found any 'modules' in 'path'
  #
  # Args:
  #   module: a character vector of module names to look for
  #   path: a file system path to look for the modules
  #
  # Returns:
  #   TRUE if any matching modules were found in path, else FALSE
  #
  # Let us genuflect briefly toward a coding standard that calls for
  # a dozen lines of documentation for a one line "alias"
  length(modulePath(module, path)) > 0
}

# Save out the basic setup that is used in later build scripts

# Non-Standard: Keep this list in an easy maintain format:
# commas precede the item so it can be moved, or deleted, or a
# new item added without having to edit more than one line.

save(
  file="dependencies.RData"
  , .First
  , checkVEEnvironment
  , ve.root
  , ve.install
  , ve.output
  , ve.runtime
  , ve.lib
  , ve.repository
  , CRAN.mirror
  , modulePath
  , moduleExists
  , ve.repo.url
  , pkgs.db
  , pkgs.all
  , pkgs.CRAN
  , pkgs.BioC
  , pkgs.external
  , pkgs.visioneval
  , pkgs.copy
)
