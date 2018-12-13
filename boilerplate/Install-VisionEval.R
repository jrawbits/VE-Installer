# VisionEval initialization script
# Run once to install everything and build VisionEval.Rdata

# Set an option to force end-user style installation on Windows
# (force "binary" even if a newer source package is available for compilation).
# Note that on Linux or MacOS, source packages are always used.
# Compiling the sources can be beastly for big packages.

options(install.packages.compile.from.source="never")

# As configured, if a newer source is available but consists only of
# R code, the newer source package will still be used.
# To force only binary packages in all cases, uncomment the following

# options(install.packages.check.source="no")

require(utils)

# Flag to determine if we want to write a result at the end
install.success <- FALSE

# Put the current directory into ve.root
ve.root <- getwd()

# Put the library directory into ve.lib
# Note that ve.lib is already present and fully provisioned if we've unzipped the offline installer
ve.lib <- file.path(ve.root,"ve-lib")

if ( ! dir.exists(ve.lib) ) {
	# We'll presume that if ve-lib can be found, it has what we need
	# If not, delete ve-lib and re-run installation

	# We can also look in the build environment for ve-lib
	ve.lib.local <- normalizePath(file.path(ve.root,"..","ve-lib"),winslash="/",mustWork=FALSE)

	if (! dir.exists(ve.lib.local) ) {
		# ve.lib can't be found locally, so pull it in from a repository
		# Configure repository depending on installation source
		# Check first for development environment
		ve.local  <- normalizePath(file.path(ve.root,"..","pkg-repository"),winslash="/",mustWork=FALSE)

		if ( dir.exists(ve.local) ) {  
			ve.repos <- paste("file:",ve.local,sep="")
		} else if ( exists("ve.remote") ) {
			ve.repos <- ve.remote
		} else {
			message("Need accessible ve-lib in the file system, or you may define ve.remote (URL for the VisionEval package repository) in .Rprofile")
			message("VisionEval packages are not available")
			return(FALSE)
		}

		VE.pkgs <- available.packages(repos=ve.repos)[,"Package"]
		# Installation list is everything in the repository
		# Consequently: test and abort if visioneval isn't in it
		if ( ! "visioneval" %in% VE.pkgs[,Package] ) {
			message(paste("VisionEval not present in",ve.repos))
			message("VisionEval packages are not available")
			return(FALSE)
		}

		dir.create(ve.lib)

		install.packages(
			VE.pkgs,
			lib=ve.lib,
			repos=ve.repos,
			quiet=TRUE
		)
	} else {
		ve.lib <- ve.lib.local # Use the build environment installed library
	}
	TRUE
}

# Construct "RunVisionEval.Rdata"
# Something to "double-click" in windows for a rapid happy start in RGui...

.First <- function() {
	.libPaths(ve.lib)
	if ( install.success <- require(visioneval) ) {
		setwd(ve.root)
		cat("Welcome to VisionEval!\n")
	}
	install.success
}

# Function starts the VEGUI
# NOTE: VEGUI remains a moving target...
vegui <- function() {
	require("shiny")
	full_path <- file.path(ve.root,"VEGUI")
	old.path <- setwd(full_path)
	runApp('../VEGUI')
	setwd(old.path)
}

# The following two functions run the command line model versions per the
# Getting Started document.  Expects a version of VE that can run a model
# from arbitrary data folders.
verpat <- function() {
	if ( ! dir.exists("defs") || ! dir.exists("inputs") ) {
		cat("Set working directory to location of 'defs' and 'inputs' for RPAT model run\n")
		cat("Look for 'models/VERPAT' or 'models/BaseYearVERPAT', for example\n")
	} else {
		source(file.path(ve.root,"models/Run_VERPAT.R"))
	}
	# WARNING: not actually using the Run_Model.R in models/VERPAT
}

verspm <- function() {
	if ( ! dir.exists("defs") || ! dir.exists("inputs") ) {
		cat("Set working directory to location of 'defs' and 'inputs' for RPAT model run\n")
		cat("Look for 'models/VERSPM/Test1' or 'models/VERSPM/Test2', for example\n")
	} else {
		source(file.path(ve.root,"models/Run_VERSPM.R"))
	}
	# WARNING: not actually using the Run_Model.R in models/VERSPM
}

install.success <- .First()
if ( install.success ) {
	save(file="RunVisionEval.RData"
		,ve.root
		,ve.lib
		,.First
		,vegui
		,verpat
		,verspm
	)
} else {
	cat("Installation failed - check error and warning messages.\n")
}
