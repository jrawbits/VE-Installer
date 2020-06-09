# Replace the Makefile with an R builder function
# Transitional to putting the build system back into VisionEval(-dev)

local({
  # Better repository setting for non-interactive installs
  # Replace with your preferred CRAN mirror
  r <- getOption("repos")
  r["CRAN"] <- "https://cloud.r-project.org"
  options(repos=r)
})

# Write scripts to reset each build step based on the config
ve.build.modules <- list(
  config=list(
    Path="scripts/build-config.R",
    Deps=character(0),
    Reset=""
    ),
  repository=list(
    Path="scripts/build-repository.R",
    Deps=character(0),
    Reset=""
    ),
  external=list(
    Path="scripts/build-external.R",
    Deps="repository",
    Reset=""
    ),
  velib=list(
    Path="scripts/build-velib.R",
    Deps="repository",
    Reset=""
    )
  modules=list(
    Path="scripts/build-modules.R",
    Deps=c("velib"),
    Reset=""
    ),
  runtime=list(
    Path="scripts/build-runtime.R",
    Deps=character(0),
    Reset=""
    ),
  docs=list(
    Path="scripts/build-docs.R",
    Deps="modules",
    Reset=""
    ),
  inventory=list(
    Path="scripts/build-inventory.R",
    Deps=c("modules"),
    Reset=""
    ),
  runtime.pkg.bin=list(
    Path="scripts/build-runtime-packages-bin.R",
    Deps="modules",
    Reset=""
    ),
  installer.base=list(
    Path="scripts/build-installer-base.R",
    Deps=c("runtime","docs"),
    Reset=""
  ),
  installer.bin=list(
    Path="scripts/build-installer-bin.R",
    Deps=c("inventory", "runtime.pkg.bin","installer.base"),
    Reset=""
    ),
  runtime.pkg.src=list(
    Path="scripts/build-runtime-packages-full.R",
    Deps=c("inventory"),
    Reset=""
    ),
  installer.full=list(
    Path="scripts/build-installer-full.R",
    Deps=c("installer.base","runtime.pkg.src"),
    Reset=""
    ),
)

ve.build.sequence = c(
  "config",
  "repository",
  "external",
  "velib",
  "modules",
  "runtime",
  "docs",
  "inventory",
  "runtime.pkg.bin",
  "installer.base",
  "installer.bin",
  "runtime.pkg.src",
  "installer.full"
)

ve.build <- function(
  modules="runtime", # list of build steps (no special order)
  build=TRUE,        # if FALSE, do reset if requested but do not rebuild
  reset=FALSE,       # if TRUE, call reset before each build step
  dependencies=TRUE) # add dependencies to build steps

  # Determine what to reset and do that first
  # If reset is requested, we will run the reset script
  #   for given build step (which will remove the artifacts of
  #   that step) prior to rebuilding it
  # Reset is not order dependent - we'll reset everything listed
  # Create some shortcut .built markers for things that are all
  # or nothing... Let's keep a time stamp on each build process
  # and when it runs.

  # Then do the build in the right order

  # Set up build order
  build.set <- modules
  add.module <- function(build.set,module) {
    build.set <- c(build.set,module)
    if ( dependencies ) {
      for ( m in module$Deps ) build.set <- add.module(build.set,m)
    }
  }
  for ( m in modules ) build.set <- add.deps(build.set,m)

  build.set <- unique(build.set)
  build.set <- ve.build.sequence[ names(ve.build.sequence) %in% build.set ]
  return(build.set)
  
  # Create the build environment for VisionEval
  env.loc <- grep("^ve.env$",search())
  ve.env <- if ( length( env.loc>0 ) ) {
    ve.env <- as.environment(env.loc[1])
    if ( reset ) rm(list=ls(env.log[1]))
  } else {
    attach(NULL,name="ve.env")
  }

  # Set the "developer" elements of the build environment
  # independent on the version we're building, only on the R environment).
  evalq({
    this.R <- paste(R.version[c("major","minor")],collapse=".")

    # Keep development packages separate from ve-lib (runtime packages)
    ve.dev <- file.path(getwd(),"dev") # Used to set log file location  
    dev.lib <- file.path(ve.dev,"lib",this.R)
    if ( ! dir.exists(dev.lib) ) dir.create( dev.lib, recursive=TRUE, showWarnings=FALSE )
    .libPaths(c(dev.lib,.libPaths()))
  },envir=ve.env)

  
# We're going to source the individual scripts within ve.env
if ( length(modules)==0 ) {
  modules <- c("config")
} else {
  
}

for ( module in modules ) {
  sys.source(ve.build.modules[[module]]$Path,envir=ve.env)
}

# Expect to have VE_CONFIG set in the environment, or sought in standard' places:
# "build/config/VE-config.yml" or "config/VE-config.yml"
# VE_R_VERSION is determined by the R running this builder script.

# The output includes the branch:

# += /built
#    += /<branch>
#       +- /<r.version>
#          +- models
#          +- VEGUI
#          ... [This IS the runtime]
#          +- docs
#          +- src
#          +- ve.lib
#          +- ve-pkgs (was: pkg-dependencies)
#          +- disney
pkg-repository (keep changes in ve-pkgs too)

# Rather than keep the build steps all separate, we should have an easy configuration based on
# intended application.  What do you want to build?
#    - Runtime: Run it locally for debug/development?
#    - Documentation: (Re)build documentation PDFs? (make it bulletproof in case they don't have the wiki; don't clean)
#    - Platform Installer: Build installer zip file for my platform?
#    - Package Source Installer: Build pacakage source zip file? (also builds manifest)
#    - "Pure source" installer (compile everything for any platform)?
# All of those check artifact time stamps and report "no changes" if artifact is newer
# Any of those can have a "reset" flag, which will ignore the existing artifact(s) and rebuild

# The configuration of a build target includes the list of scripts that will be run
# Each script has a list of sources and artifacts that need to be checked (VE-config/VE-components
# will identify those) to decide if it is "up to date" - that list is ignored if we reset, and
# we delete all the output from that step.  Each step is associated (currently, implicitly) with
# a specific output location (possibly just certain files there). We can make that association
# explicit.

# In the build-repository step, don't pull down the sources unless that's what our platform needs
# (then don't do binaries for it), or unless we're making a "pure source" installer. Otherwise we
# pull binary dependencies (and build just that for the externals).

# In addition to the structural configuration, each script needs information on the build target
# status so it can adjust what it does. So launching the build probably should ALWAYS rebuild the
# config and report on out-of-date targets.

# Alternatively (and initially) could use sys.source in a local environment to make it go


# buildfun <- function(script.name,envir=NULL,chdir=getwd()) {
#   function() sys.source(script.name,env=envir,chdir=chdir)
# }
# 
# 
# build.steps = list(
#   configure = list(
#     build = buildfun("build-config.R")
#     reset = 
#     ),
#   repository = list(),
#   binary = list(),
#   modules = list(),
#   runtime = list(),
#   docs = list(),
#   module.list = list(),
#   installer = list(),
#   installer.src = list(),
# )
# 
# ve.build <- function(
#   build=c("all")      # may include any of the Makefile build target names
#   reset=character(0)  # may include any of the Makefile -clean target neames
# ) {
#   # visit the reset targets in their own hierarchical order
#   # visit the build targets in their own hierarchical order (as recoded from Makefile)
# }
# 
# 
