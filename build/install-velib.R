# Script to install all required packages into ve.lib from within the local miniCRAN
# This will install the packages necessary for the local runtime environment
# (source on Linux or MacOS; binaries on Windows, with an option to compile if Rtools is installed)

# you will need miniCRAN and dependencies installed in your local R environment
if (!suppressWarnings(require(miniCRAN))) {
	install.packages("miniCRAN",repos=CRAN.mirror)
}
# We install these locally prior to the VE package build process (as a backstop
# to ensure that all required packages really are in the VE repository).
# NOTE: it is a bad idea to put the VE dependencies in your development environment
# since you will not easily be able to tell if you missed on in the documentation

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

# uncomment the following line on Windows if you just want the pre-compiled binaries
# otherwise, if RTools is installed the newer sources packages will be compiled.
# You should allow compilation to happen if there is discrepancy in behavior between
# a Windows installation and a source (e.g. Linux/Docker) installation
options(install.packages.compile.from.source="never")

sought.pkgs <- miniCRAN::pkgDep( c(pkgs.CRAN,pkgs.BioC), repos=ve.repo.url, suggests=FALSE )
pkgs.BaseR <- as.vector(installed.packages(lib.loc=.Library,priority=c("base","recommended"))[,"Package"])

sought.pkgs <- setdiff(sought.pkgs,pkgs.BaseR)
# cat("Final sought packages:\n")
# print(sort(sought.pkgs))
# cat("---End of revised sought.pkgs---\n")

new.pkgs <- sought.pkgs[!(sought.pkgs %in% installed.packages(lib.loc=ve.lib)[,"Package"])]

if(length(new.pkgs)>0) {
    cat("---Still missing these packages:\n")
    print(sort(new.pkgs))
	print(ve.lib)
    cat("---Installing missing packages---\n")
    install.packages(
        new.pkgs,
        lib=ve.lib,
        repos=ve.repo.url,
        dependencies=c("Depends","Imports","LinkingTo")
    )
    cat("---Finished installing---\n")
} else {
    cat("All dependencies accounted for in ve-lib\n")
}
