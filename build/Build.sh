#!/bin/bash
# (expecting Git for Windows or Git on Linux)

# It's probably safer, less resource intensive, and more informative to
# do these steps manually one at a time, but here's the full train ready
# to roll, and secondarily serving as documentation of what needs to
# happen.

# Make sure to set up VE-config.R (path to VisionEval) and
# VE-dependencies.csv which lists what has to be built
# in the 'dependencies' directory.

do_step()
 {
	printf '=%.0s' {1..20}
	echo " Build step: $2 $1"
	if [ -z "$2" ]
	then
		Rscript $1 || exit
	else
		$2 $1 || exit
	fi
	printf '=%.0s' {1..40}; echo
}

do_step "state-dependencies.R"	     # the master list of VE dependencies
do_step "build-repository.R"		 # the VE repository lives locally
do_step "build-external-src.R"       # external (Github) packages as configured
do_step "build-packages-src.R"       # VisionEval packages as configured
do_step "setup-sources.R"			 # copy the modules and VEGUI to the install/runtime staging area
# do_step "build-docker.sh" "bash"   # build the docker image

# Need the following for local installation, or for building the Windows installer
do_step "install-velib.R"			 # install the required VE packages to ve-lib
do_step "build-external-bin.R"       # Build binary external packages
do_step "build-packages-bin.R"		 # Build binary Windows / local packages

# Can do the following step with or without the local/Windows installation
# If ve-lib is not installed, then it will only build the online installer
do_step "build-installers.sh" "bash" # these also land in a web-ready location

# Website is currently set up as a clone of my git repository,
# so only the repository gets rsync'ed
# do_step "publish-installers.sh" "bash"  # Push the package repository directory to the website
