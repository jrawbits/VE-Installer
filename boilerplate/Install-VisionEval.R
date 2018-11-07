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
	# We'll presume that if it's there, it has what we need (if not, delete it and re-run installation)
	# That allows a "pure windows installer" with the lib directory pre-loaded

	# Configure repository depending on installation source
	ve.remote <- "https://visioneval.jeremyraw.com/R/"
	ve.local  <- normalizePath(file.path(ve.local,"..","miniCRAN"),winslash="/",mustWork=FALSE)# see if the development environment is available

	dir.create(ve.lib)

	# Install the VE packages and dependencies
	# If it looks like we have suitable 'src' and 'bin' in a local 'R' folder, use that for packages
	# Otherwise, reach for the default online server

	ve.repos <- ifelse( dir.exists(ve.local), paste("file:",ve.local,sep=""), ve.remote )
	VE.pkgs <- available.packages(repos=ve.repos)[,"Package"] # Installation list is everything in the miniCRAN

	# Don't do dependencies because they should all be in the miniCRAN
	install.packages(
		VE.pkgs,
		lib=ve.lib,
		repos=ve.repos,
		quite=TRUE
	)
	install.success <- TRUE
}

# Construct "RunVisionEval.Rdata"
# Something to "double-click" for a rapid happy start in RGui.

# TODO: We'll want to do some better library-finding
# I'd recommend blowing away all the library paths except the
# one that has the base packages, then forcing ve.lib to the
# front of the list as is done here.  But it's rather hard
# to get R to throw away libraries it already knows about.

.First <- function() {
	.libPaths(ve.lib)
	if ( install.success <- require(visioneval) ) {
		setwd(ve.root)
		cat("Welcome to VisionEval!\n")
	}
	install.success
}
install.success <- .First()

# The following convenience functions have not been well-tested.
# They probably don't work, e.g., for the RSG development branch

# Function starts the VEGUI
vegui <- function() {
	require("shiny")
	full_path <- file.path(ve.root,"VEGUI")
	setwd(full_path)
	runApp('../VEGUI')
	setwd(ve.root)
}

# The following two functions run the command line version per the
# Getting Started document

verpat <- function() {
	full_path = file.path(ve.root,"models/VERPAT")
	setwd(full_path)
	source("run_model.R")
	setwd(ve.root)
}

verspm <- function() {
	full_path = file.path(ve.root,"models/VERSPM")
	setwd(full_path)
	source("run_model.R")
	setwd(ve.root)
}

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

