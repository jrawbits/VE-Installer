#!/bin/bash
# (expecting Git for Windows or Git on Linux)

# It's probably safer, less resource intensive, and more informative to
# do these steps manually one at a time, but here's the full train ready
# to roll, and secondarily serving as documentation of what needs to
# happen.

# This expects to find a clean clone of the install tree from git
# Visit 'external' to make sure you have 'rsync' in Git for Windows

# pushd ../external
# bash install-rsync.sh
# popd

do_step() {
	printf '=%.0s' {1..20}
	echo " Build step: $1"
	$1 || exit
	printf '=%.0s' {1..40}; echo
}

do_step "Rscript state-dependencies.R"  # the master list of VE dependencies
do_step "Rscript build-miniCRAN.R"      # the miniCRAN lives in a
do_step "Rscript build-external.R"      # build the package(s) from an external submodule
do_step "Rscript install-velib.R"       # install the required VE packages to ve-lib
do_step "Rscript build-packages.R"      # Prepare installable visioneval; has a number of annoying user dependencies like rhdf5
do_step "Rscript addVE-to-miniCRAN.R"   # add the VE (and local) packages we just built to miniCRAN and ve-lib
do_step "Rscript setup-sources.R"       # copy the modules and VEGUI to the install/runtime staging area
do_step "bash build-installers.sh"      # these also land in a web-ready location

# Website is currently set up as a clone of my git repository, so only the miniCRAN gets rsync'ed
# bash publish-installers.R # Loads the miniCRAN directory out to the website
