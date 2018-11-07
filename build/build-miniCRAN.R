#!/bin/R
# This script installs required R packages from CRAN and BioConductor

print(.libPaths())
if (!suppressWarnings(require(miniCRAN))) {
	install.packages("miniCRAN",repos=CRAN.mirror)
}
require(tools)

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

# Fix up any partially complete repository stuff (this will happen, e.g., if build-miniCRAN.R is interrupted)
# And it will save us re-downloading packages that happen already to be in the miniCRAN.

have.packages <- function() {
	src.contrib <- contrib.url(ve.miniCRAN,type="source")
	bin.contrib <- contrib.url(ve.miniCRAN,type="win.binary")
	got.src <- FALSE
	got.bin <- FALSE
	if ( dir.exists(file.path(ve.miniCRAN,"src")) ) {
		if ( ! file.exists(file.path(src.contrib,"PACKAGES")) ) {
			cat("Updating miniCRAN source PACKAGES files\n")
			got.src <- (write_PACKAGES(src.contrib,type="source")>0)
		} else {
			got.src <- TRUE
		}
	}
	if ( dir.exists(file.path(ve.miniCRAN,"bin")) ) {
		if ( ! file.exists(file.path(bin.contrib,"PACKAGES")) ) {
			cat("Updating miniCRAN win.binary PACKAGES files\n")
			got.bin <- (write_PACKAGES(bin.contrib,type="win.binary")>0)
		} else {
			got.bin <- TRUE
		}
	}
	got.src && got.bin
}

cat("\nComputing dependencies.\n")
pkgs.CRAN <- miniCRAN::pkgDep(pkgs.CRAN,repos=CRAN.mirror,suggests=FALSE)
pkgs.CRAN <-  setdiff(pkgs.CRAN,pkgs.BaseR) # don't keep base packages

pkgs.BioC <- miniCRAN::pkgDep(pkgs.BioC,repos=bioc,suggests=FALSE)
pkgs.BioC <- setdiff( pkgs.BioC, pkgs.CRAN ) # Possible risk here: don't double-install packages

# Attempt a minimal build of the miniCRAN (adding just new packages if we already have the whole thing)
# We won't attempt to delete - cleanup just by rebuilding when cruft gets to be too much.
if ( have.packages() ) {
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
	cat("Existing miniCRAN is up to date.\n")
} else {
	cat("Building miniCRAN from CRAN packages\n")
	miniCRAN::makeRepo(pkgs.CRAN,path=ve.miniCRAN,repos=CRAN.mirror,type=c("source","win.binary"))

	cat("Adding BioConductor packages to new miniCRAN\n")
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
