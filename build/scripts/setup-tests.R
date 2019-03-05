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

if ( ! suppressWarnings(require(yaml)) ) {
  install.packages("yaml", repos="https://cloud.r-project.org", dependencies=NA)
}

# Create a "Tests" folder in ve.output
# Get the list of tests by FOLDER and SCRIPT from .travis.yml
# in the env: section of travis 

# For now, you only get one "tests" document

test.paths <- normalizePath(file.path(pkgs.tests[,"Root"], pkgs.tests[,"Path"], pkgs.tests[,"Package"]))
num.files <- length(test.paths)

tests.raw <- character(0)
cat("Loading tests...\n")
for ( tfn in test.paths[1] ) {  # only look at the first one
  cat("Loading tests from",tfn,"\n")
  tests.raw <- c(tests.raw, yaml::yaml.load_file(tfn)$env )
}
cat("Loaded",length(tests.raw),"tests.\n")

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
cat("Parsed",nrow(df),"tests.\n")

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
df$SOURCE[models] <- sub("sources/","",df$SOURCE[models])

# Directory into which to copy the test scripts and data
df$DEST <- file.path(ve.test,df$CHANGETO)

# Clear out any previous tests and run everything again
cat("Clearing test directories:\n")
print(df$DEST)
unlink( df$DEST, recursive=TRUE, force=TRUE )
for ( dst in df$DEST ) dir.create( dst, recursive=TRUE, showWarnings=FALSE )

# Now copy everything into the test environment.
cat("Copying test files\n")
for ( i in 1:nrow(df) ) {
  cat("Copying",df$SOURCE[i],"\n")
  cat("To",df$DEST[i],"...\n")
  files2copy <- dir(df$SOURCE[i],all.files=TRUE,full.names=TRUE,recursive=TRUE)
  numfiles <- length(files2copy)
  file.copy( files2copy, df$DEST[i], recursive=TRUE )
  cat("Done copying",numfiles,"files.\n")
}

do.tests <- file.path(ve.test,"do-tests.sh")
sink( file=do.tests, type="output" )
for ( i in 1:nrow(df) ) {
  cat("cd",file.path(ve.test,df$CHANGETO[i]),"; pwd;","echo $RSCRIPT",df$SCRIPT[i],"\n"
}
sink() # Turn off sink and close test file

warnings()
