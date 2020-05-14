#!/bin/env Rscript

# Author: Jeremy Raw

# uncomment the following line on Windows if you just want the pre-compiled
# binaries otherwise, if RTools is installed the newer sources packages will be
# compiled.  You should allow compilation to happen if there is discrepancy in
# behavior between a Windows installation and a source (e.g. Linux/Docker)
# installation
options(install.packages.compile.from.source="never")

# Load the yaml library
# Note: hardwire installation source to the cloud of CRAN repository mirrors
# Subsequent package installations will come from the dependency repository for this
# R version, contained in R-versions.yml

if ( ! suppressWarnings(require(yaml)) ) {
  install.packages("yaml", repos="https://cloud.r-project.org", dependencies=NA, type=.Platform$pkgType )
}
if ( ! suppressWarnings(require(git2r)) ) {
  install.packages("git2r", repos="https://cloud.r-project.org", dependencies=NA, type=.Platform$pkgType )
}

# Identify the platform and supported binary package built types
ve.platform <- .Platform$OS.type # Used to better identify binary installer type
ve.platform <- paste(toupper(substring(ve.platform,1,1)),substring(ve.platform,2),sep="")
ve.binary.build.types <- c("win.binary","mac.binary","mac.binary.el-capitan")
ve.build.type <- .Platform$pkgType
ve.binary.build <- ve.build.type %in% ve.binary.build.types
if ( ! ve.binary.build ) {
  ve.build.type <- "source"
}

# Locate the installer tree (used for boilerplate)
# The following includes a hack to fix a common path problem if you are
# developing on Windows in a subfolder of "My Documents"
ve.installer <- getwd()
if ( ve.platform == "Windows" || ve.build.type == "win.binary" ) {
  ve.installer <- sub("My Documents", "Documents", ve.installer)
  ve.installer <- gsub("\\\\", "/", ve.installer)
} else if ( ve.platform == "Unix" && ve.build.type %in% c("mac.binary","mac.binary.el-capitan") ) {
  ve.platform <- "MacOSX"
}

# Specify dependency repositories
cat("Loading R versions\n")
rversions <- yaml::yaml.load_file("R-versions.yml")
this.R <- paste(R.version[c("major","minor")],collapse=".")
CRAN.mirror <- rversions[[this.R]]$CRAN
BioC.mirror <- rversions[[this.R]]$BioC

# Get the logs location
ve.logs <- Sys.getenv("VE_LOGS",file.path(getwd(),"logs",winslash="/"))

# Read the configuration file
ve.config.file <- Sys.getenv("VE_CONFIG","config/VE-config.yml")
cat(paste("Loading Configuration File:",ve.config.file,"\n",sep=" "))
if ( !file.exists(ve.config.file) ) {
  stop("Configuration file",ve.config.file,"not found.")
}
ve.cfg <- yaml::yaml.load_file(ve.config.file)

# Extracting root paths, plus branch if specified.
branches <- character(0)
# branches is a named vector - name is the root, value is the branch
if ( "Roots" %in% names(ve.cfg) ) {
  ve.roots <- names(ve.cfg$Roots)
  ve.branches <- invisible(
    sapply(
      ve.roots,
      FUN=function(x,venv) {
        rt <- ve.cfg$Roots[[x]]
        nt <- names(rt)
        br <- ""
        rtp <- ifelse ( "path" %in% nt , rt$path , rt )
        assign(x,normalizePath(rtp,winslash="/"),pos=venv);
        if ( "branch" %in% nt ) {
            br <- rt$branch     # Vector element is branch
            cat("Root",x,"requires branch",paste0("'",rt$branch,"'"),"\n")
        }
        names(br) = x       # Vector name is root
        return(br)
      },
      venv=sys.frame(),
      USE.NAMES=FALSE
    )
  )
} else {
  stop("No roots in",ve.config.file,"- Check file format.")
}

# Check if branch is correct for roots that specify it
# branches is a named vector - name is the root, value is the branch

# Helper function
checkBranchOnRoots <- function(roots,branches) {
  rtb <- names(branches)
  for ( rt in roots ) {
    # It's okay if there is not branch (i.e. not github)
    # but it's an error if there is a local branch name and it doesn't match
    br <- branches[rt]
    if ( length(br)==1 && !is.null(br) && !is.na(br) && nchar(br)>0 ) {
      repopath <- get(rt)
      cat("Examining branch for root",rt,paste0("<",repopath,">"),"which should be",paste0("'",br,"'"),"\n")
      if ( git2r::in_repository(repopath) ) {
        # Find the currently checked out branch by looking at HEAD for local branches
        # cat("Need branch",paste0("<",br,">"),"on repository",repopath,"\n")
        localbr <- git2r::branches(repopath,flags="local")
        hd <- which(sapply(localbr,FUN=git2r::is_head,simplify=TRUE))
        hd <- localbr[[hd]]$name
        # cat("Have branch",paste0("<",hd,">"),"on repository",repopath,"\n")
        if ( hd != br) {
          cat(paste("Root",rt,"wants branch",paste0("<",br,">"),"but has",paste0("<",hd,">")),"\n")
          return(FALSE)
        }
      } else {
        cat(paste("Branch",paste0("'",br,"'"),"specified, but",repopath,"is not a Git repository.\n"),"\n")
        return(FALSE)
      }
    }
  }
  return(TRUE)
}

# Invoke helper function before continuing to apply branch constraint
if ( checkBranchOnRoots(ve.roots,ve.branches) ) {
  for ( b in branches ) {
    if ( length(b)==1 && nchar(b)>0 ) cat("Building root",paste0("'",names(b),"'"),"from branch",paste0("'",b,"'"),"\n")
  }
  rm(b)
} else {
  stop("Incorrect branch specified for root.\n")
}

# rtb <- names(branches)
# # cat("names of branches:\n")
# # print(rtb)
# for ( rt in ve.roots ) {
#   if ( rt %in% rtb ) {
#     # It's okay if there is not branch (i.e. not github)
#     # but it's an error if there is a local branch name and it doesn't match
#     br <- branches[rt]
#     if ( length(br)==1 && !is.null(br) && !is.na(br) && nchar(br)>0 ) {
#       repopath <- get(rt)
#       cat("Examining branch for root",rt,paste0("<",repopath,">"),"which should be",paste0("'",br,"'"),"\n")
#       if ( git2r::in_repository(repopath) ) {
#         # Find the currently checked out branch by looking at HEAD for local branches
#         # cat("Need branch",paste0("<",br,">"),"on repository",repopath,"\n")
#         localbr <- git2r::branches(repopath,flags="local")
#         hd <- which(sapply(localbr,FUN=git2r::is_head,simplify=TRUE))
#         hd <- localbr[[hd]]$name
#         # cat("Have branch",paste0("<",hd,">"),"on repository",repopath,"\n")
#         if ( hd != br) {
#           stop(paste("Config",ve.config.file,"wants branch",paste0("<",br,">"),"but has",paste0("<",hd,">")))
#         } else {
#           cat("Building from branch",paste0("'",hd,"'"),"\n")
#         }
#       } else {
#         stop(paste("Branch",paste0("'",br,"'"),"specified, but",repopath,"is not a Git repository.\n"))
#       }
#     }
#   }
# }
cat("Building into",ve.output,"\n")

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

# Create the .Renviron file in ve.output so dev-lib is included
# That way we can have things like rmarkdown that are not needed by the runtime
# (see VE-installer .Rprofile for construction of dev-lib location)
r.environ <- file.path(ve.output,this.R,".Renviron")
dev.lib <- normalizePath(dev.lib,winslash="/")
ve.lib  <- normalizePath(ve.lib,winslash="/")
cat("Creating .Renviron at",r.environ,"\n")
r.libs.user <- paste0("R_LIBS_USER=",paste(ve.lib,dev.lib,sep=";"))
write(r.libs.user,file=r.environ)
rm( r.environ,r.libs.user )

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

# catn <- function(...) { cat(...); cat("\n") }

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

# catn("Sorted by Group:")
# print(pkgs.db[,c("Type","Package","Group")])

# Helper function for other scripts, to verify situational awareness

checkVEEnvironment <- function() {
  # Check for situational awareness, and report if we are lost
  # Returns 0 or 1
  if ( ! suppressWarnings(requireNamespace("git2r")) ) {
    cat("Cannot find git2r - needed to check repository branch")
    return(FALSE)
  }
  if ( ! exists("ve.installer") || is.na(ve.installer) || ! file.exists(ve.installer) ) {
    cat("Missing ve.installer; run build-config.R\n")
    return(FALSE)
  } else if ( ! exists("ve.repository") || is.na(ve.repository) ) {
    cat("Missing ve.repository definition; run build-config.R\n")
    return(FALSE)
  } else if ( ! exists("ve.dependencies") || is.na(ve.dependencies) ) {
    cat("Missing ve.dependencies definition; run build-config.R\n")
    return(FALSE)
  } else if ( ! exists("ve.runtime") || is.na(ve.runtime) ) {
    cat("Missing ve.runtime definition; run build-config.R\n")
    return(FALSE)
  } else if ( ! exists("ve.pkgs") || is.na(ve.pkgs) ) {
    cat("Missing ve.pkgs definition; run build-config.R\n")
    return(FALSE)
  } else if ( ! exists("ve.lib") || is.na(ve.lib) ) {
    cat("Missing ve.lib definition; run build-config.R\n")
    return(FALSE)
  } else if ( ! exists("ve.roots") || ! exists("ve.branches") || ! checkBranchOnRoots(ve.roots,ve.branches) ) {
    cat("Missing roots, or incorrect branches\n")
    return(FALSE)
  }
  return(TRUE)
}

.First <- function() {
  # If you try to load dependencies.N.N.N.RData interactively in an incomplete
  # environment, you will be busted (e.g. by checking it accidentally into
  # your repository and then checking out somewhere else without setting up
  # the environment, or if you damage the environment by changing the name
  # of the VisionEval source tree root).
  if ( ! exists("checkVEEnvironment") || ! checkVEEnvironment() ) {
    stop("Please configure VE-config.yml, then source('build-config.R')")
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
newerThan <- function( srcpath, tgtpath, quiet=TRUE ) {
  # Compare modification time for a set of files to a target file
  #
  # Args:
  #   srcpath - a single folder containing a bunch of files that might be newer, or a vector of files
  #   tgtpath - one (or a vector) of files that may be older, or may not exist
  #   quiet - if TRUE, then print a message about what is being tested
  #
  # Value: TRUE if the most recently modified source file is newer
  #        than the oldest target file
  if (!quiet) cat("Comparing",srcpath,"to",paste(tgtpath,collapse="\n"),"\n")
  if ( any(is.null(srcpath)) || any(is.na(srcpath)) || any(nchar(srcpath))==0 || ! file.exists(srcpath) ) return(TRUE)
  if ( any(is.null(tgtpath)) || any(is.na(tgtpath)) || any(nchar(tgtpath))==0 || ! file.exists(tgtpath) ) return(TRUE)
  if ( dir.exists(srcpath) ) srcpath <- file.path(srcpath,dir(srcpath,recursive=TRUE,all.files=FALSE))
  if ( dir.exists(tgtpath) ) tgtpath <- file.path(tgtpath,dir(tgtpath,recursive=TRUE,all.files=FALSE))
  if ( length(tgtpath) < 1 ) return(TRUE)
  source.time <- file.mtime(srcpath)
  target.time <- file.mtime(tgtpath)
  source.newest <- order(source.time,decreasing=TRUE)
  target.newest <- order(target.time,decreasing=TRUE)
  if (!quiet) cat("Source path:",srcpath[source.newest[1]],strftime(source.time[source.newest[1]],"%d/%m/%y %H:%M:%S"),"\n")
  if (!quiet) cat("Target:",tgtpath[target.newest[1]],strftime(target.time[target.newest[1]],"%d/%m/%y %H:%M:%S"),"\n")
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
  list=c(ve.roots,locs.lst)
  , .First
  , checkVEEnvironment
  , checkBranchOnRoots
  , ve.roots
  , ve.branches
  , ve.output
  , ve.logs
  , ve.installer
  , ve.build.type
  , ve.binary.build
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
