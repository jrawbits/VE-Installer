#!/bin/R
# This script installs required R packages from CRAN and BioConductor

# Pick the CRAN mirror to use for the packages
CRAN.mirror <- "https://cran.rstudio.org"

if (!suppressWarnings(require(miniCRAN))) {
	install.packages("miniCRAN",repos=CRAN.mirror)
}

# BioConductor setup
# They're moving 2018-11 to a new version that is not, as yet, compatible with miniCRAN
if (!suppressWarnings(require(BiocInstaller))) {
	cat("Installing BioConductor Installer\n")
	bioc <- local({
	  env <- new.env()
	  on.exit(rm(env))
	  evalq(source("http://bioconductor.org/biocLite.R", local = TRUE), env)
	  biocinstallRepos()
	})
}
bioc <- biocinstallRepos()

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

if ( !exists("pkgs.CRAN") || !exists("pkgs.BioC") ) {
	stop("Please run state-dependencies.R to build dependency lists")
}

# Base R packages (so we can ignore those as dependencies)
base.lib <- dirname(find.package("MASS")) # looking for recommended packages; picking one that is required
pkgs.BaseR <- as.vector(installed.packages(lib.loc=base.lib,priority=c("base","recommended"))[,"Package"])
cat("Base packages:\n")
print(pkgs.BaseR)

cat("\nComputing dependencies:\n")
# miniCRAN additions (if we want miniCRAN itself in the repository - there's no need)
# pkgs.miniCRAN <- miniCRAN::pkgDep("miniCRAN",repos=CRAN.mirror,suggests=FALSE)

pkgs.CRAN <- miniCRAN::pkgDep(pkgs.CRAN,repos=CRAN.mirror,suggests=FALSE)
pkgs.CRAN <-  setdiff(pkgs.CRAN,pkgs.BaseR) # don't keep base packages

pkgs.BioC <- miniCRAN::pkgDep(pkgs.BioC,repos=bioc,suggests=FALSE)
pkgs.BioC <- setdiff( pkgs.BioC, pkgs.CRAN ) # Possible risk here: don't double-install packages

cat("Building miniCRAN from CRAN packages, then adding BioConductor\n")
miniCRAN::makeRepo(pkgs.CRAN,path=path.miniCRAN,repos="https://cran.rstudio.org",type=c("source","win.binary"))

# BioConductor depends on some CRAN packages - no need to download those twice, so deps=FALSE
miniCRAN::addPackage(pkgs.BioC,path=path.miniCRAN,repos=bioc,type=c("source","win.binary"),deps=FALSE)

# Verify the miniCRAN using the following independent cross-check of dependencies to make sure everything needed is there

# pkgs.miniCRAN <- c(pkgs.CRAN,pkgs.BioC)
# ap <- available.packages(repos=repo.miniCRAN())
# get.dependencies <- function(x) {
# 	strsplit(split=",[ \n]*",paste( (y<-x[c("Package","Depends","Imports","Extends","LinkingTo")])[!is.na(y)],collapse=", "))
# }
# pkg <- sort(unique(unlist(apply(ap,1,get.dependencies))))
# pkg <- unique(sub("( |\\n)*\\(.*\\)","",pkg))
# pkg <- setdiff(pkg,c(pkgs.BaseR,"R")) # Kill the BaseR packages from the list of dependencies, as well as dependency on R itself
# if ( length(setdiff(pkgs.miniCRAN,pkg))>0 ) {
# 	cat("Discrepancy:\n")
# 	print(setdiff(pkgs.miniCRAN,pkg))
# } else if (length(setdiff(pkg,pkgs.miniCRAN))>0 ) {
# 	cat("Discrepancy:\n")
# 	print(setdiff(pkg,pkgs.miniCRAN))
# } else {
# 	cat("miniCRAN contents are complete\n")
# }
