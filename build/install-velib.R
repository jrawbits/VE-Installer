# Script to install all required packages into ve.lib from within the local miniCRAN
# This will install the packages necessary for the local runtime environment
# (source on Linux or MacOS; binaries on Windows, with an option to compile if Rtools is installed)

# you will need miniCRAN and dependencies installed in your local R environment
if (!suppressWarnings(require(miniCRAN))) {
	install.packages("miniCRAN",repos=CRAN.mirror)
}
# We install these locally prior to the VE package build process (as a backstop
# to ensure that all required packages really are in the miniCRAN).

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

# uncomment the following line on Windows if you just want the pre-compiled binaries
# otherwise, if RTools is installed the newer sources packages will be compiled.
# You should allow compilation to happen if there is discrepancy in behavior between
# a Windows installation and a source (e.g. Linux/Docker) installation
options(install.packages.compile.from.source="never")

if ( ! dir.exists(ve.runtime) ) dir.create(ve.runtime)
if ( ! dir.exists(ve.lib) ) dir.create(ve.lib)

ve.repos <- repo.miniCRAN()

sought.pkgs <- miniCRAN::pkgDep( c(pkgs.CRAN,pkgs.BioC), repos=ve.repos, suggests=FALSE )
base.repos <- dirname(find.package("MASS")) # looking for recommended packages; picking one that is required
pkgs.BaseR <- as.vector(installed.packages(lib.loc=base.repos,priority=c("base","recommended"))[,"Package"])

sought.pkgs <- setdiff(sought.pkgs,pkgs.BaseR)
# cat("Final sought packages:\n")
# print(sort(sought.pkgs))
# cat("---End of revised sought.pkgs---\n")

new.pkgs <- sought.pkgs[!(sought.pkgs %in% installed.packages(lib.loc=ve.lib)[,"Package"])]

if(length(new.pkgs)>0) {
    cat("---Still missing these packages:\n")
    print(sort(new.pkgs))
	print(ve.lib)
    cat("---End of missing packages---\n")
    install.packages(
        new.pkgs,
        lib=ve.lib,
        repos=ve.repos,
        dependencies=c("Depends","Imports","LinkingTo")
    )
    cat("Finished installing.\n")
} else {
    cat("Everything seems to be there.\n")
}
