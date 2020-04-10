#!/bin/env Rscript

# Author: Jeremy Raw

# Build the package inventory and model usage tables (in ve.test)

# Load runtime configuration
default.config <- paste("logs/dependencies",paste(R.version[c("major","minor")],collapse="."),"RData",sep=".")
ve.runtime.config <- Sys.getenv("VE_RUNTIME_CONFIG",default.config)
if ( ! file.exists(normalizePath(ve.runtime.config,winslash="/")) ) {
  stop("Missing VE_RUNTIME_CONFIG",ve.runtime.config,
       "\nRun build-config.R to set up build environment")
}
load(ve.runtime.config)
if ( ! checkVEEnvironment() ) {
  stop("Run build-config.R to set up build environment")
}
if ( ! dir.exists(ve.test) ) {
  stop("Need to make modules before building inventory.\n")
}

# Reach for ve.lib first when seeking packages used by the ones we're
# building
.libPaths( c(ve.lib, .libPaths()) ) # push runtime library onto path stack

# Libraries from ve.lib:
require(visioneval)
require(jsonlite)

# Need to work in ve.test to support visioneval structure
setwd(ve.test)

# Find module packages and models

ve.packages <- pkgs.db[pkgs.module,]$Package
ve.models <- pkgs.db[pkgs.model,]$Package

# For each module package, find the list of data elements and extract those ending with
# "Specifications"

modules <- data.frame(Item=character(0),Package=character(0))
for ( p in ve.packages ) {
  d <- data(package=p,lib.loc=ve.lib)
  items <- d$results[,"Item"]
  items <- items[grep("Specifications$",items)] # d$results, and thus "items", is an R matrix
  if ( length(items) < 1 ) {
    cat("No registry items for package '",p,"'\n")
    next
  }
  items <- unlist(strsplit(items,"Specifications"))
  modules <- rbind(modules,data.frame(Item=items,Package=p))
}

# writeVENameRegistry weirdly requires the registry file already to exist
NameRegistryFile <- file.path(ve.test,"VENameRegistry.json")
NameRegistry_ls <- list(Inp=list(),Set=list())

cat("Registry calls:\n")
registry <- apply(modules,1,function(x) {
    cat("Item=",x["Item"],"; Package=",x["Package"],"\n")
    visioneval::writeVENameRegistry(x["Item"],x["Package"],NameRegistryList=TRUE)
  }
)

for ( m in registry ) {
  NameRegistry_ls$Inp <- c(NameRegistry_ls$Inp,m$Inp)
  NameRegistry_ls$Set <- c(NameRegistry_ls$Set,m$Set)
}

writeLines(toJSON(NameRegistry_ls,pretty=TRUE),NameRegistryFile)

# TODO: go through the model run_model.R scripts and extract module calls,
# then add to the inventory which models the modules are used in...
# Use "TestMode" with visioneval::parseModelScript.

# Visit each component model, and parse its Run_Model script.
# Add a "Models" element to the "Modules" list (a character vector) and
# append the Model name to each Module that appears in that Model's parsed run_model.R script.
