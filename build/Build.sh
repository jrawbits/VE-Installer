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
do_step "install-velib.R"			 # install the required VE packages to ve-lib
do_step "build-external.R"			 # build any package(s) from an external (Github) submodule
do_step "build-packages.R"			 # Prepare installable visioneval; has a number of annoying user dependencies like rhdf5
do_step "update-repository.R"		 # Update the VE repository PACKAGES list with built packages
do_step "setup-sources.R"			 # copy the modules and VEGUI to the install/runtime staging area
do_step "build-installers.sh" "bash" # these also land in a web-ready location

# Website is currently set up as a clone of my git repository,
# so only the repository gets rsync'ed
# bash publish-installers.R # Loads the repository directory out to the website
