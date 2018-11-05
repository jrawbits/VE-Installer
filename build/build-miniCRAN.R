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

# Attempt a minimal build of the miniCRAN (adding just new packages if we already have the whole thing)
# We won't attempt to delete - cleanup just by rebuilding when cruft gets to be too much.
if ( dir.exists(file.path(ve.miniCRAN,"src")) && dir.exists(file.path(ve.miniCRAN,"bin")) ) {
	ap <- available.packages(repos=repo.miniCRAN())
	pkgs.present <- ap[,"Package"]
	pkgs.missing.CRAN <- setdiff(pkgs.CRAN, pkgs.present)
	if ( length(pkgs.missing.CRAN) ) {
		cat("Updating miniCRAN to add from CRAN:\n")
		print(pkgs.missing.CRAN)
		pkgs.missing.CRAN <- miniCRAN::pkgDep(pkgs.missing.CRAN,repos=CRAN.mirror,suggests=FALSE)
		pkgs.missing.CRAN <- setdiff(pkgs.missing.CRAN,pkgs.present)
		miniCRAN::addPackage(pkgs.missing.CRAN,path=ve.miniCRAN,repos=CRAN.mirror,type=c("source","win.binary"))
	}
	pkgs.missing.BioC <- setdiff(pkgs.BioC, pkgs.present)
	if ( length(pkgs.missing.BioC) ) {
		cat("Updating miniCRAN to add from BioConductor:\n")
		print(pkgs.missing.BioC)
		pkgs.missing.BioC <- miniCRAN::pkgDep(pkgs.missing.BioC,repos=bioc,suggests=FALSE)
		pkgs.missing.BioC <- setdiff(pkgs.missing.BioC,pkgs.present)
		miniCRAN::addPackage(pkgs.missing.BioC,path=ve.miniCRAN,repos=bioc,type=c("source","win.binary"),deps=FALSE)
	}
} else {
	cat("Building miniCRAN from CRAN packages, then adding
	BioConductor\n")
	miniCRAN::makeRepo(pkgs.CRAN,path=ve.miniCRAN,repos=CRAN.mirror,type=c("source","win.binary"))

	# BioConductor depends on some CRAN packages - no need to download those twice, so deps=FALSE
	miniCRAN::addPackage(pkgs.BioC,path=ve.miniCRAN,repos=bioc,type=c("source","win.binary"),deps=FALSE)
}

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
