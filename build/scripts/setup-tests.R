#!/bin/env Rscript

# Author: Jeremy Raw

# This script runs all the configured tests; track with the travis.yml
# environment

# Iterate across the packages, finding their test scripts and executing those
# one after another. Then run VERPAT on its test data, and VERSPM and its test
# data

load("dependencies.RData")
if ( ! checkVEEnvironment() ) {
  stop("Run state-dependencies.R to set up build environment")
}

# Create a "Tests" folder in ve.output
# Get the list of tests by FOLDER and SCRIPT from .travis.yml
# in the env: section of travis 

# For now, you only get one "tests" document

test.paths <- file.path(pkgs.tests[,"Root"], pkgs.tests[,"Path"], pkgs.tests[,"Package"])
num.files <- length(test.paths)

tests.raw <- character(0)
cat("Loading tests...\n")
for ( tfn in test.paths[1] ) {  # only look at the first one
  cat("Loading tests from",tfn,"\n")
  tests.raw <- c(tests.raw, yaml::yaml.load_file(tfn)$env )
}

tx <- strsplit(tests.raw,"[[:space:]]+") # FOLDER, SCRIPT, TYPE, DEPENDS
lntx <- length(tx)
holder <- character(lntx)
df <- data.frame("FOLDER"=I(holder),"NAME"=I(holder),"SCRIPT"=I(holder),"TYPE"=I(holder))
for ( t in seq_along(tx) ) {
  varbles <- strsplit(tx[[t]],split="=")
  for ( v in varbles ) {
    if ( v[1] == "FOLDER" ) {
      df[t,"NAME"] <- basename(v[2])
      df[t,"FOLDER"] <- dirname(v[2])
    } else if ( v[1] %in% c("SCRIPT","TYPE") ) {
      df[t,v[1]] <- v[2]
    }
  }
}

# Figure out where to copy the test hierarchies from
# Modules are copied from their ve.root locations
# Models are copied from the runtime location
df$ROOT <- ""
modules <- which(df$TYPE=="module")
row.names(pkgs.visioneval) <- pkgs.visioneval$Package
pkgidx <- match(df$NAME[modules],pkgs.visioneval$Package)
df$ROOT[modules] <- pkgs.visioneval[ pkgidx, "Root" ]

models <- which(df$TYPE=="model")
df$ROOT[models] <- ve.runtime

# Whence to copy the code for the tests
df$SOURCE <- ""
df$SOURCE[modules] <- file.path(df$ROOT[modules],df$FOLDER[modules],df$NAME[modules],"tests")
df$SOURCE[models] <- file.path(df$ROOT[models],df$FOLDER[models],df$NAME[models])

# Directories in which to run test scripts
df$CHANGETO <- sub("^.*sources/","",df$SOURCE)
df$CHANGETO[modules] <- sub("^framework/","",df$CHANGETO[modules])
df$CHANGETO[modules] <- sub("^modules/","",df$CHANGETO[modules])
df$CHANGETO[modules] <- sub("/tests$","",df$CHANGETO[modules])

# Directory into which to copy the test scripts and data
df$DEST <- file.path(ve.test,df$CHANGETO)

# Clear out any previous tests and run everything again
unlink( df$DEST, recursive=TRUE, force=TRUE )
for ( dst in df$DEST ) dir.create( dst, recursive=TRUE, showWarnings=FALSE )

# Now copy everything into the test environment.
for ( i in 1:nrow(df) ) {
  file.copy( file.path(df$SOURCE[i],dir(df$SOURCE)[i]), df$DEST[i], recursive=TRUE )
}
