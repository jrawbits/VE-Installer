#!/bin/env Rscript

# Author: Jeremy Raw

# Load the yaml library
# Note: hardwire installation source to the cloud of CRAN repository mirrors
# Subsequent installations will come from the dependency repository

if ( ! suppressWarnings(require(yaml)) ) {
  install.packages("yaml", repos="https://cloud.r-project.org", dependencies=NA)
}

# Identify the platform
ve.platform <- .Platform$OS.type # Used to better identify binary installer type
ve.platform <- paste(toupper(substring(ve.platform,1,1)),substring(ve.platform,2),sep="")

# Locate the installer tree (used for boilerplate)
# The following includes a hack to fix a common path problem if you are
# developing on Windows in a subfolder of "My Documents"
ve.installer <- getwd()
if ( ve.platform == "Windows" || .Platform$pkgType == "win.binary" ) {
  ve.installer <- sub("My Documents", "Documents", ve.installer)
  ve.installer <- gsub("\\\\", "/", ve.installer)
}

# Specify dependency repositories
cat("Loading R versions\n")
rversions <- yaml::yaml.load_file("R-versions.yml")
this.R <- paste(R.version[c("major","minor")],collapse=".")
CRAN.mirror <- rversions[[this.R]]$CRAN
BioC.mirror <- rversions[[this.R]]$BioC

# Get the logs location
ve.logs <- Sys.getenv("VE_LOGS",normalizePath("./logs",winslash="/"))

# Read the configuration file
ve.config.file <- Sys.getenv("VE_CONFIG","config/VE-config.yml")
cat(paste("Loading Configuration File:",ve.config.file,"\n",sep=" "))
if ( !file.exists(ve.config.file) ) {
  stop("Configuration file",ve.config.file,"not found.")
 }
ve.cfg <- yaml::yaml.load_file(ve.config.file)

# Extracting root paths
if ( "Roots" %in% names(ve.cfg) ) {
  roots.lst <- names(ve.cfg$Roots)
  invisible(
    sapply(
      roots.lst,
      FUN=function(x,venv) {
        assign(x,normalizePath(ve.cfg$Roots[[x]],winslash="/"),pos=venv); x
      },
      venv=sys.frame()
    )
  )
}

# Default ve.root presumes VE-Installer is running in a sub-folder of VisionEval
if ( ! exists("ve.root") ) ve.root <- normalizePath("..")

# Default ve.output creates a "built" folder below VE-Installer root.
if ( ! exists("ve.output") ) {
  ve.output <- normalizePath("built")
  dir.create( ve.output, recursive=TRUE, showWarnings=FALSE )
}

# Extracting location paths:
locs.lst <- names(ve.cfg$Locations)
makepath <- function(x,venv) {
  # Build a location path from root and path and assign it
  # Note that this function is used for its SIDE-EFFECTS, not
  # its return value.
  #
  # Args:
  #   x - the name of a Location (and its veriable)
  #   venv - the environment in which to create the variable
  #
  loc <- ve.cfg$Locations[[x]]
  assign(x,file.path(get(loc$root),this.R,loc$path),pos=venv)
}
invisible(sapply(locs.lst,FUN=makepath,venv=sys.frame()))

# Create the locations
# Packages and libraries are distinguished by R versions since the
# R versions are sometimes hidden and we may want to use the same
# VE-config.yml with different versions of R (e.g. 3.5.1 and 3.5.2)

for ( loc in locs.lst ) dir.create( get(loc), recursive=TRUE, showWarnings=FALSE )

# Determine whether build should include tests
# Look at environment (possibly from Makefile) then at ve.cfg
# Result is TRUE (run tests) or FALSE (skip tests)
ve.runtests <- switch(
  tolower(Sys.getenv("VE_RUNTESTS",unset="Default")),
  false=FALSE,
  true=TRUE,
  ! is.null(ve.cfg[["RunTests"]]) && all(ve.cfg[["RunTests"]])
  )
cat("ve.runtests is",ve.runtests,"\n")

# Convey key file locations to the 'make' environment
make.target <- Sys.getenv("VE_MAKEVARS",unset=file.path(ve.logs,"ve-output.make"))
make.variables <- c(
   VE_R_VERSION = this.R
  ,VE_PLATFORM  = ve.platform
  ,VE_INSTALLER = ve.installer
  ,VE_OUTPUT    = ve.output
  ,VE_LIB       = ve.lib
  ,VE_REPOS     = ve.repository
  ,VE_PKGS      = ve.pkgs
  ,VE_RUNTIME   = ve.runtime
  ,VE_TEST      = ve.test
  ,VE_RUNTESTS  = ve.runtests
  ,VE_DEPS      = ve.dependencies
)

writeLines( paste( names(make.variables), make.variables, sep="="),make.target)

# The following are constructed in Locations above, and must be present
# ve.runtime <- file.path(ve.output, "runtime")
# ve.lib <- file.path(ve.output, "ve-lib",this.R)
# ve.repository <- file.path(ve.output, "pkg-repository")
# ve.dependencies
# ve.runtime

# ve.dependencies hosts the external R packages
# ve.repository hosts the built VE packages
ve.deps.url <- paste("file:", ve.dependencies, sep="")
ve.repo.url <- paste("file:", ve.repository, sep="")

# Load the Components

catn <- function(...) { cat(...); cat("\n") }

# ve.components can be set as a location in VE-config.yml
if ( ! exists("ve.components") ) ve.components <- file.path( ve.root,"build/VE-components.yml" )
if ( ! file.exists(ve.components) ) stop("Cannot find VE-components.yml in VisionEval build folder")
component.file <- c( ve.root = ve.components )
includes <- list()
excludes <- list()
##### WARNING - we make use of the fact that:
#   "ve.root" will always be at component.file[1] !!!!
if ( "Components" %in% names(ve.cfg) ) {
  comps <- ve.cfg$Components
  components.lst <- names(comps)
#   catn("Component list from VE-config.yml:")
#   print(components.lst)
  for ( root in components.lst ) {
    if ( ! exists(root) ) {
      stop(paste("Undefined",root,"in Roots: section of",ve.config.file,sep=" "))
    }
#     catn("Root:",root,"is",get(root))
#     print(names(comps[[root]]))
    component.file[root] <- file.path( get(root),comps[[root]]$Config )
    if ( "Include" %in% names(comps[[root]]) ) {
      includes[[root]] <- comps[[root]]$Include
#       cat("Includes from",root,"\n")
#       print(includes[[root]])
    } else {
      includes[[root]] <- character(0)
    }
    if ( "Exclude" %in% names(comps[[root]]) ) {
      excludes[[root]] <- comps[[root]]$Exclude
#       catn("Excludes from",root)
#       print(comps[[root]]$Exclude)
    } else {
      excludes[[root]] <- character(0)
    }
  }
}

# Process component.file like this:
#   1. Load components from file into temporary list
#   2. Add component from "Include" if not empty
#   3. Else skip component if it's in "Exclude"
#   4. Put each remaining element of temporary list into final
#      component list (by component name, so there is replacement)

build.comps <- list()
for ( root in names(component.file) ) {
#   catn("Processing components for",root,"from",component.file[root])
  comps <- ve.cfg <- yaml::yaml.load_file(component.file[root])$Components
  if ( is.null(comps) ) stop("Failed to find components in",component.file[root])
  for ( cn in names(comps) ) {
    comp <- comps[[cn]]
    if ( ( length(excludes[[root]])==0 || ! cn %in% excludes[[root]] ) &&
         ( length(includes[[root]])==0 || cn %in% includes[[root]] ) ) {
      comp$Root <- get(root) # retrieves path from variable whose name is in 'root'
      build.comps[[cn]] <- comp
    }
  }
}
# catn("Build roots:")
# print(names(build.comps))
# print(build.comps[[names(build.comps)[2]]])

# Parse the Components for Dependencies
# Do this in a specific order:
#   "Type: module"
#      Within Module by Test$Group
#      Within Group in order from build.comps
#   "Type: model"
#   "Type: test"
#   "Type: script"

pkgs.db <- data.frame(Type="Type",Package="Package",Root="Root",Path="Path",Group=0,Test="Test")
save.types <- c("module","model","script","test")
# iterate over build.comps, creating dependencies
for ( pkg in names(build.comps) ) {
  it <- build.comps[[pkg]]
  if ( it$Type %in% save.types ) {
    it.db <- data.frame(Type=it$Type,Package=pkg,Root=it$Root,Path=it$Path)
    if ( "Test" %in% names(it) ) {
      tst <- names(it[["Test"]])
      if ( "Group" %in% tst ) {
        it.db$Group <- it$Test$Group
      } else {
        it.db$Group <- NA
      }
      if ( "Script" %in% tst ) {
        it.db$Test <- it$Test$Script
      } else {
        it.db$Test <- ""
      }
    } else {
      it.db$Group <- NA
      it.db$Test <- ""
    }
    pkgs.db <- rbind(pkgs.db,it.db)
    if ( "CRAN" %in% names(it) ) {
      for ( dep in it$CRAN ) {
        dep.db <- data.frame(Type="CRAN",Package=dep,Root=NA,Path=NA,Group=NA,Test=NA)
        pkgs.db <- rbind(pkgs.db,dep.db)
      }
    }
    if ( "BioC" %in% names(it) ) {
      for ( dep in it$BioC ) {
        dep.db <- data.frame(Type="BioC",Package=dep,Root=NA,Path=NA,Group=NA,Test=NA)
        pkgs.db <- rbind(pkgs.db,dep.db)
      }
    }
    if ( "Github" %in% names(it) ) {
      for ( dep in it$Github ) {
        dep.db <- data.frame(Type="Github",Package=basename(dep),Root=NA,Path=dep,Group=NA,Test=NA)
        pkgs.db <- rbind(pkgs.db,dep.db)
      }
    }
  }
}
# print(pkgs.db)
pkgs.db <- unique(pkgs.db[-1,])           # Remove dummy row
row.names(pkgs.db) <- NULL                # Remove artificial row.names
for ( d in names(pkgs.db))                # Convert factors to strings
  if ( is.factor(pkgs.db[,d]) )
    pkgs.db[,d] <- as.character(pkgs.db[,d])
pkgs.db <- pkgs.db[order(pkgs.db$Type,pkgs.db$Group,pkgs.db$Package),] # Sort by Group (for modules)

# New strategy:
# We'll save pkgs.db into dependencies.N.N.N.RData
# Also save row indices of the different types

pkgs.CRAN   <- which(pkgs.db$Type=="CRAN")
pkgs.BioC   <- which(pkgs.db$Type=="BioC")
pkgs.Github <- which(pkgs.db$Type=="Github")
pkgs.module <- which(pkgs.db$Type=="module")
pkgs.model  <- which(pkgs.db$Type=="model")
pkgs.script <- which(pkgs.db$Type=="script")
pkgs.test   <- which(pkgs.db$Type=="test")

# mods <-
# unname(apply(pkgs.db[pkgs.module,c("Group","Root","Path","Package")],1,paste,collapse="/"))
catn("Sorted by Group:")
print(pkgs.db[,c("Type","Package","Group")])

# Helper function for other scripts, to verify situational awareness

checkVEEnvironment <- function() {
  # Check for situational awareness, and report if we are lost
  # Returns 0 or 1
  if ( ! exists("ve.installer") || is.na(ve.installer) || ! file.exists(ve.installer) ) {
    cat("Missing ve.installer; run state-dependencies.R\n")
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
  # If you try to load dependencies.N.N.N.RData interactively in an incomplete
  # environment, you will be busted (e.g. by checking it accidentally into
  # your repository and then checking out somewhere else without setting up
  # the environment, or if you damage the environment by changing the name
  # of the VisionEval source tree root).
  if ( ! exists("checkVEEnvironment") || ! checkVEEnvironment() ) {
    stop("Please configure VE-config.yml, then source('state-dependencies.R')")
  }
}

# The following two helpers extract modules from built packages
# Used in the scripts to detect whether a module has been built yet.
modulePath <- function( module, path ) {
  # determine which module in a vector of names is present in the
  # path
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
  # result <- mods[grep(paste("^", basename(module), "_", sep=""), mods)]
  matching <- paste("^", basename(module), "_", sep="")
  test<-sapply(matching,FUN=function(x){ grep(x,mods) },simplify=TRUE,USE.NAMES=FALSE)
  if ( class(test)=="list" ) test <- integer(0) # weirdness of sapply(simplify=TRUE) when empty
  result <- mods[test]
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
  found <- modulePath(module,path)
  found.test <- length(found)>0
}

# Helper function to compare package path (source) to a built target (modification date)
newerThan <- function( pkgpath, target, quiet=TRUE ) {
  # Compare modification time for a set of files to a target file
  #
  # Args:
  #   pkgpath - a single folder containing a bunch of files that might be newer, or a vector of files
  #   target - one (or a vector) of files that may be older, or may not exist
  #   quiet - if TRUE, then print a message about what is being tested
  #
  # Value: TRUE if the most recently modified source file is newer
  #        than the oldest target file
  if (!quiet) cat("Comparing",pkgpath,"to",paste(target,collapse="\n"),"\n")
  if ( any(is.null(target)) || any(is.na(target)) || any(nchar(target))==0 || ! file.exists(target) ) return(TRUE)
  if ( dir.exists(pkgpath) ) pkgpath <- file.path(pkgpath,dir(pkgpath,recursive=TRUE))
  source.time <- file.mtime(pkgpath)
  target.time <- file.mtime(target)
  source.newest <- order(source.time,decreasing=TRUE)
  target.newest <- order(target.time,decreasing=TRUE)
  if (!quiet) cat("Source path:",pkgpath[source.newest[1]],strftime(source.time[source.newest[1]],"%d/%m/%y %H:%M:%S"),"\n")
  if (!quiet) cat("Target:",target[target.newest[1]],strftime(target.time[target.newest[1]],"%d/%m/%y %H:%M:%S"),"\n")
  newer <- source.time[source.newest[1]] > target.time[target.newest[1]]
  if (!quiet) cat("Newer:",newer,"\n")
  newer
}

# Save out the basic setup that is used in later build scripts

# Non-Standard Coding: Keep this list in an easy maintain format:

# Commas precede the item so it can be moved, or deleted, or a new item
# added without having to edit more than one line.

default.config <- file.path(ve.logs,"dependencies.RData")
ve.runtime.config <- Sys.getenv("VE_RUNTIME_CONFIG",default.config)
ve.all.dependencies <- file.path(ve.logs,"all-dependencies.RData")

save(
  file=ve.runtime.config,
  list=c(locs.lst)
  , .First
  , checkVEEnvironment
  , ve.output
  , ve.logs
  , ve.installer
	, ve.runtests
  , ve.all.dependencies
  , CRAN.mirror
  , BioC.mirror
  , modulePath
  , moduleExists
  , newerThan
  , ve.deps.url
  , ve.repo.url
  , pkgs.db
  , pkgs.CRAN
  , pkgs.BioC
  , pkgs.Github
  , pkgs.module
  , pkgs.model
  , pkgs.script
  , pkgs.test
)
