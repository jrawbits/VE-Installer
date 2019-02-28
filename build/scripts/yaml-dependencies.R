#!/bin/env Rscript

# Author: Jeremy Raw

# Load the yaml library
# Note: hardwire installation source to the cloud of CRAN repository mirrors
# Subsequent installations will come from the dependency repository

if ( ! suppressWarnings(require(yaml)) ) {
	install.packages("yaml", repos="https://cloud.r-project.org", dependencies=NA)
}

# Locate the installer tree (used for boilerplate)
# The following includes a hack to fix a common path problem if you are
# developing on Windows in a subfolder of "My Documents"
ve.install <- sub("My Documents", "Documents",
	    normalizePath(file.path(getwd(), "..")))
ve.install <- gsub("\\\\", "/", ve.install)

# Specify dependency repositories
rversions <- yaml.load_file("R-versions.yml")
this.R <- paste(R.version[c("major","minor")],collapse=".")
CRAN.mirror <- rversions[[this.R]]$CRAN
BioC.mirror <- rversions[[this.R]]$BioC

# Read the configuration file
ve.config.file <- Sys.getenv("VE_CONFIG")
if ( ! file.exists(ve.config.file) ) {
	ve.config.file <- "../dependencies/VE-config.yml"
}
ve.cfg <- yaml::yaml.load_file(ve.config.file)

# Extracting root paths:
roots.lst <- names(ve.cfg$Roots)
invisible(sapply(roots.lst,FUN=function(x,venv){assign(x,ve.cfg$Roots[[x]],pos=venv); x},venv=sys.frame()))

# Extracting location paths:
locs.lst <- names(ve.cfg$Locations)
makepath <- function(x,venv) {
	# Build a location path from root and path
	#
	# Args:
	#   x - the name of a Location (and its veriable)
	#   venv - the environment in which to create the variable
	#
  loc <- ve.cfg$Locations[[x]]
  assign(x,file.path(get(loc$root),loc$path),pos=venv)
}
invisible(sapply(locs.lst,FUN=makepath,venv=sys.frame()))

# Create the locations
for ( loc in locs.lst ) dir.create( get(loc), recursive=TRUE, showWarnings=FALSE )

# Convey key file locations to the 'make' environment
make.target <- file("ve-output.make")
ve.platform <- .Platform$OS.type # Used to better identify binary installer type
writeLines(paste(c("VE_OUTPUT", "VE_INSTALLER", "VE_PLATFORM"),
                 c(ve.output, ve.install, ve.platform),
                 sep="="),
           make.target)
close(make.target)

# ve.runtime <- file.path(ve.output, "runtime")
# ve.lib <- file.path(ve.output, "ve-lib")
# ve.repository <- file.path(ve.output, "pkg-repository")
# ve.dependencies
# ve.runtime
# ve.pkgs

# Need to nuance the following to split pkg-dependencies (no VE)
# from pkg-repository (everything)
ve.deps.url <- paste("file:", ve.dependencies, sep="")
ve.repo.url <- paste("file:", ve.repository, sep="")

# Parse the Module and Source Listings for dependencies
# Include their dependencies:
#   CRAN
#   BioConductor
#   External

pkgs.db <- data.frame(Type="Type",Package="Package",Root="Root",Path="Path")
for ( ve.type in c("Module","Source") ) {
	items <- ve.cfg[[ve.type]] # ve.cfg[["Module"]]
	for ( pkg in names(items) ) {
		it <- items[[pkg]]
		it.db <- data.frame(Type=ve.type,Package=pkg,Root=get(it$root),Path=it$path)
		pkgs.db <- rbind(pkgs.db,it.db)
		if ( "CRAN" %in% names(it) ) {
			for ( dep in it$CRAN ) {
				dep.db <- data.frame(Type="CRAN",Package=dep,Root=NA,Path=NA)
				pkgs.db <- rbind(pkgs.db,dep.db)
			}
		}
		if ( "BioC" %in% names(it) ) {
			for ( dep in it$BioC ) {
				dep.db <- data.frame(Type="BioC",Package=dep,Root=NA,Path=NA)
				pkgs.db <- rbind(pkgs.db,dep.db)
			}
		}
		if ( "External" %in% names(it) ) {
			for ( dep in it$External ) {
				ex.nm <- names(dep)
				dep <- dep[[ex.nm]]
				dep.db <- data.frame(Type="External",Package=ex.nm,Root=get(dep$root),Path=dep$path)
				pkgs.db <- rbind(pkgs.db,dep.db)
			}
		}
	}
}

# Produce the various package lists for retrieval
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
    pkgs.db[which(pkgs.db["Type"]==type), c("Package", "Root", "Path")]
  }
}
pkgs.all        <- getPackageList()
pkgs.CRAN       <- getPackageList("CRAN")
pkgs.BioC       <- getPackageList("BioC")
pkgs.external   <- getPackageList("External", path=TRUE)
pkgs.visioneval <- getPackageList("Module", path=TRUE)
pkgs.copy       <- getPackageList("Source", path=TRUE)

# Helper function for other scripts, to verify situational awareness

checkVEEnvironment <- function() {
  # Check for situational awareness, and report if we are lost
  # Returns 0 or 1
  if ( ! exists("ve.install") || is.na(ve.install) || ! file.exists(ve.install) ) {
    cat("Missing ve.install; run state-dependencies.R\n")
    return(FALSE)
  } else if ( ! exists("ve.repository") || is.na(ve.repository) ) {
    cat("Missing ve.repository definition; run state-dependencies.R\n")
    return(FALSE)
  } else if ( ! exists("ve.dependencies") || is.na(ve.dependencies) ) {
    cat("Missing ve.dependencies definition; run state-dependencies.R\n")
    return(FALSE)
  } else if ( ! exists("ve.runtime") || is.na(ve.runtime) ) {
    cat("Missing ve.runtime definition; run state-dependencies.R\n")
    return(FALSE)
  } else if ( ! exists("ve.pkgs") || is.na(ve.pkgs) ) {
    cat("Missing ve.pkgs definition; run state-dependencies.R\n")
    return(FALSE)
  } else if ( ! exists("ve.lib") || is.na(ve.lib) ) {
    cat("Missing ve.lib definition; run state-dependencies.R\n")
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
    stop("Please configure VE-config.yml, then source('yaml-depedencies.R')")
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
  file="dependencies.RData",
	list=c(locs.lst)
  , .First
  , checkVEEnvironment
  , ve.install
	, ve.output
  , CRAN.mirror
  , BioC.mirror
  , modulePath
  , moduleExists
	, ve.deps.url
  , ve.repo.url
  , pkgs.db
  , pkgs.all
  , pkgs.CRAN
  , pkgs.BioC
  , pkgs.external
  , pkgs.visioneval
  , pkgs.copy
)
