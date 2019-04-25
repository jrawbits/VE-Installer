#!/bin/bash
# Author: Jeremy Raw

# (expecting Git for Windows or Git on Linux)
# The script is written to run from its parent directory
# (typically "build") with the scripts in the scripts sub-directory
# where this script (Build.sh) is itself located.

# Rather than use this script, if you have "make" installed,
# you can just do the grouped steps by calling the makefile:
#     make repository
#     make binary (generally only on Windows)
#     make installers (builds online installer only unless 'binary' is built first)
#     make publish (if configured, moves the pkg-repository and installers to the website)
#     make docker (generally only on Linux)

# docker build is only available through the Makefile

# Make sure to set up VE-config.R (path to VisionEval) and
# VE-dependencies.csv which lists what has to be built
# in the 'dependencies' directory.

do_step()
 {
	printf '=%.0s' {1..20}
	echo " Build step: $2 $1"
	if [ -z "$2" ]
	then
		Rscript "scripts/$1" || exit
	else
		$2 "scripts/$1" || exit
	fi
	printf '=%.0s' {1..40}; echo
}

# Set up source repository (windows also from CRAN/BioConductor)
do_step "state-dependencies.R"	     # the master list of VE dependencies
do_step "build-repository.R"		 # the VE repository lives locally
do_step "build-external-src.R"       # external (Github) packages as configured
do_step "build-packages-src.R"       # VisionEval packages as configured

# Need the following for local installation, or for building the Windows installer
do_step "install-velib.R"			 # install the required VE packages to ve-lib
do_step "build-external-bin.R"       # Build binary external packages
do_step "build-packages-bin.R"		 # Build binary Windows / local packages

# Construct installers from what is available
do_step "setup-sources.R"			 # copy the modules and VEGUI to the install/runtime staging area
# Can do the following step with or without the local/Windows installation
# If ve-lib is not installed, then it will only build the online installer
do_step "build-installers.sh" "bash" # these also land in a web-ready location

# Website is currently set up as a clone of my git repository,
# so only the repository gets rsync'ed
# do_step "publish-installers.sh" "bash"  # Push the package repository directory to the website
