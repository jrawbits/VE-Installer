#!/bin/R
# This script installs required R packages from CRAN and BioConductor

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

if (!suppressWarnings(require(miniCRAN))) {
	install.packages("miniCRAN",repos=CRAN.mirror,dependencies=NA)
}
require(tools)

# BioConductor setup
if (!requireNamespace("BiocManager"))
    install.packages("BiocManager",repos=CRAN.mirror)
bioc <- BiocManager::repositories()

if ( !exists("pkgs.CRAN") || !exists("pkgs.BioC") ) {
	stop("Please run state-dependencies.R to build dependency lists")
}

# Base R packages (so we can ignore those as dependencies)
base.lib <- dirname(find.package("MASS")) # looking for recommended packages; picking one that is required
pkgs.BaseR <- as.vector(installed.packages(lib.loc=base.lib,priority=c("base","recommended"))[,"Package"])

# Fix up any partially complete repository stuff (this will happen, e.g., if build-repository.R is interrupted)
# And it will save us re-downloading packages that happen already to be in the repository.

# A couple of helper functions
# have.packages: check for presence of basic repository structure
# find.missing.packages: list packages not present in a particular sub-repository

have.packages <- function() {
	src.contrib <- contrib.url(ve.repository,type="source")
	bin.contrib <- contrib.url(ve.repository,type="win.binary")
	got.src <- FALSE
	got.bin <- FALSE
	if ( dir.exists(file.path(ve.repository,"src")) ) {
		if ( ! file.exists(file.path(src.contrib,"PACKAGES")) ) {
			cat("Updating VE repository source PACKAGES files\n")
			got.src <- (write_PACKAGES(src.contrib,type="source")>0)
		} else {
			got.src <- TRUE
		}
	}
	if ( dir.exists(file.path(ve.repository,"bin")) ) {
		if ( ! file.exists(file.path(bin.contrib,"PACKAGES")) ) {
			cat("Updating VE repository win.binary PACKAGES files\n")
			got.bin <- (write_PACKAGES(bin.contrib,type="win.binary")>0)
		} else {
			got.bin <- TRUE
		}
	}
	got.src && got.bin
}

find.missing.packages <- function( required.packages ) {
	aps <- available.packages(repos=ve.repo.url,type="source")
	apb <- available.packages(repos=ve.repo.url,type="win.binary")
	list(
		src=setdiff( required.packages, aps[,"Package"]),
		bin=setdiff( required.packages, apb[,"Package"])
		)
}

cat("\nComputing dependencies.\n")
pkgs.CRAN.all <- pkgs.CRAN <- miniCRAN::pkgDep(pkgs.CRAN,repos=CRAN.mirror,suggests=FALSE)
pkgs.CRAN <-  setdiff(pkgs.CRAN,pkgs.BaseR) # don't keep base packages

pkgs.BioC.all <- pkgs.BioC <- miniCRAN::pkgDep(pkgs.BioC,repos=bioc,suggests=FALSE)
pkgs.BioC <- setdiff( pkgs.BioC, pkgs.CRAN ) # Possible risk here: don't double-install packages

cat("Dependencies:\n")
stated.dependencies <- as.character(c(pkgs.CRAN,pkgs.BioC))
all.dependencies <- as.character(c(pkgs.CRAN.all,pkgs.BioC.all))
save(stated.dependencies,all.dependencies,file="all-dependencies.RData")

# Attempt a minimal build of the repository (adding just new packages if we already have the whole thing)
# We won't attempt to delete - cleanup just by rebuilding when cruft gets to be too much.
if ( have.packages() ) {
	pkgs.missing.CRAN <- find.missing.packages(pkgs.CRAN)
	if ( any(sapply(pkgs.missing.CRAN,length))>0 ) {
		cat("Updating VE repository to add from CRAN:\n")
		print(union(pkgs.missing.CRAN$src,pkgs.missing.CRAN$bin))
		if ( length(pkgs.missing.CRAN$src)>0 ) {
			miniCRAN::addPackage(pkgs.missing.CRAN$src,path=ve.repository,repos=CRAN.mirror,type=c("source"),deps=FALSE)
		}
		if ( length(pkgs.missing.CRAN$bin)>0 ) {
			miniCRAN::addPackage(pkgs.missing.CRAN$bin,path=ve.repository,repos=CRAN.mirror,type=c("win.binary"),deps=FALSE)
		}
	}
	pkgs.missing.BioC <- find.missing.packages(pkgs.BioC)
	if ( any(sapply(pkgs.missing.BioC,length))>0 ) {
		cat("Updating VE repository to add from BioConductor:\n")
		print(union(pkgs.missing.BioC$src,pkgs.missing.BioC$bin))
		if ( length(pkgs.missing.BioC$src)>0 ) {
			miniBioC::addPackage(pkgs.missing.BioC$src,path=ve.repository,repos=bioc,type=c("source"),deps=FALSE)
		}
		if ( length(pkgs.missing.BioC$bin)>0 ) {
			miniBioC::addPackage(pkgs.missing.BioC$bin,path=ve.repository,repos=bioc,type=c("win.binary"),deps=FALSE)
		}
	}
	cat("Existing VE repository is up to date.\n")
} else {
	cat("Building VE repository from scratch from CRAN packages\n")
	miniCRAN::makeRepo(pkgs.CRAN,path=ve.repository,repos=CRAN.mirror,type=c("source","win.binary"))

	cat("Adding BioConductor packages to new VE repository\n")
	# BioConductor depends on some CRAN packages - no need to download those twice, so deps=FALSE
	miniCRAN::addPackage(pkgs.BioC,path=ve.repository,repos=bioc,type=c("source","win.binary"),deps=FALSE)
}

# Verify the VE Repository with the following independent cross-check of dependencies

# pkgs.VE <- c(pkgs.CRAN,pkgs.BioC)
# ap <- available.packages(repos=ve.repo.url)
# get.dependencies <- function(x) {
# 	strsplit(split=",[ \n]*",paste( (y<-x[c("Package","Depends","Imports","Extends","LinkingTo")])[!is.na(y)],collapse=", "))
# }
# pkg <- sort(unique(unlist(apply(ap,1,get.dependencies))))
# pkg <- unique(sub("( |\\n)*\\(.*\\)","",pkg))
# pkg <- setdiff(pkg,c(pkgs.BaseR,"R")) # Kill the BaseR packages from the list of dependencies, as well as dependency on R itself
# if ( length(setdiff(pkgs.VE,pkg))>0 ) {
# 	cat("Discrepancy:\n")
# 	print(setdiff(pkgs.VE,pkg))
# } else if (length(setdiff(pkg,pkgs.VE))>0 ) {
# 	cat("Discrepancy:\n")
# 	print(setdiff(pkg,pkgs.VE))
# } else {
# 	cat("VE repository contents are complete\n")
# }
