# This script just compiles all the VisionEval dependencies and makes
# them available to other scripts such as build-miniCRAN.R

# Required input:  VE-dependencies.csv in ve.install/dependencies
#   with columns "Package","Type","Path"
#   Choices for "Type" are
#		"CRAN"
#		"BioConductor",
#		"install" (a package, such as namedCapture, located in the install tree)
#		"visioneval" (for the visioneval packages)
#       "copy" (for the visioneval source trees [models,vegui])
#   The path is a path string relative sub-folders
#		relative to ve.install for "install" Repository
#		relative to ve.root for "visioneval" Repository
# If there is a dependency order among the VE modules, they must be listed in
# VE-dependencies.csv in the order in which they will be built

# Can override ve.install in .Rprofile (default presumes the working
# directory is the "build" subdirectory of the installer root)

if (!exists("ve.install") || is.na(ve.install) || !file.exists(ve.install) ) {
	ve.install <- sub("My Documents","Documents",normalizePath(file.path(getwd(),".."))) # Hack to fix path problem
}
ve.dependencies <- file.path(ve.install,"dependencies")
source(file.path(ve.dependencies,"VE-config.R"))

if (!exists("ve.output") || is.na(ve.output) || !file.exists(ve.output) ) {
	ve.output <- file.path(ve.install,paste("installer",format(Sys.time(),"%y%m%d"),sep="_"))
}
	
ve.runtime <- file.path(ve.output,"runtime")
ve.lib <- file.path(ve.runtime,"ve-lib")
ve.built <- file.path(ve.output,"built-packages")
ve.miniCRAN <- file.path(ve.output,"miniCRAN")

# Create the basic output tree
dir.create(ve.runtime,recursive=TRUE,showWarnings=FALSE)
dir.create(ve.lib,recursive=TRUE,showWarnings=FALSE)
dir.create(ve.built,recursive=TRUE,showWarnings=FALSE)
dir.create(ve.miniCRAN,recursive=TRUE,showWarnings=FALSE)

# Produce the various package lists for retrieval
pkgs.db <- read.csv(file.path(ve.dependencies,"VE-dependencies.csv"))
pkglist <- function(repos="",path=FALSE) {
	if ( !path ) {
		as.character(
			if (repos>"") {
				pkgs.db[which(pkgs.db["Type"]==repos),"Package"]
			} else {
				pkgs.db[,"Package"]
			}
		)
	} else {
		pkgs.db[which(pkgs.db["Type"]==repos),c("Package","Path")]
	}
}
pkgs.all		<- pkglist()
pkgs.CRAN		<- pkglist("CRAN")
pkgs.BioC		<- pkglist("BioConductor")
pkgs.external	<- pkglist("install",path=TRUE)
pkgs.visioneval	<- pkglist("visioneval",path=TRUE)
pkgs.copy       <- pkglist("copy",path=TRUE)

# NOTE: there is an order dependency for building/checking modules
# Generally, it is important to use the list in the order presented below
# framework <- "visioneval"
# modules <- c(
# 	 "VE2001NHTS"
# 	,"VESyntheticFirms"
# 	,"VESimHouseholds"
# 	,"VELandUse"
# 	,"VETransportSupply"
# 	,"VETransportSupplyUse"
# 	,"VEHouseholdTravel"
# 	,"VEHouseholdVehicles"
# 	,"VEPowertrainsAndFuels"
# 	,"VETravelPerformance"
# 	,"VEReports"
# 	)
 
# Create a series of utility functions
check.VE.environment <- function() {
	if (!exists("ve.root") || is.na(ve.root) || !file.exists(ve.root) ) {
		cat("Missing ve.root - set in .RProfile to root of VE repository\n")
		return(0)
	} else if (!exists("ve.install") || is.na(ve.install) || !file.exists(ve.install) ) {
		cat("Missing ve.install - set in .RProfile to root of installer tree\n")
		return(0)
	} else if (!exists("ve.lib") || is.na(ve.lib) ) {
		cat("Missing ve.lib definition; run state-dependencies.R\n")
		return(0)
	} else if (!exists("ve.miniCRAN") || is.na(ve.miniCRAN) ) {
		cat("Missing ve.miniCRAN definition; run state-dependencies.R\n")
		return(0)
	}
	return(1)
}

.First <- function() {
	if ( ! exists("check.VE.environment") || ! check.VE.environment() ) {
		stop("Please set ve.root and ve.install in .Rprofile, then source('state-depedencies.R')")
	}
}

repo.miniCRAN <- function() {
	paste("file:",ve.miniCRAN,sep="")
}

module.path <- function( module,path ) {
	mods <- dir(path)
	result <- mods[grep(paste("^",basename(module),"_",sep=""),mods)]
}

module.exists <- function( module,path ) {
	length(module.path(module,path))>0
}

# Save out the basic setup that is used in later build scripts
save(
	file="dependencies.RData"
	,.First
	,check.VE.environment
	,ve.root
	,ve.install
	,ve.output
	,ve.runtime
	,ve.lib
	,ve.built
	,ve.miniCRAN
	,module.path
	,module.exists
	,repo.miniCRAN
	,pkgs.db
	,pkgs.all
	,pkgs.CRAN
	,pkgs.BioC
	,pkgs.external
	,pkgs.visioneval
	,pkgs.copy
)
