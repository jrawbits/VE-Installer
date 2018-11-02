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

Rscript state-dependencies.R || exit # the master list of VE dependencies
Rscript build-miniCRAN.R     || exit # the miniCRAN lives in a
Rscript build-external.R     || exit # build the package(s) from an external submodule
Rscript install-velib.R	     || exit # install the required VE packages to ve-lib
Rscript build-packages.R     || exit # Prepare installable visioneval; has a number of annoying user dependencies like rhdf5
Rscript addVE-to-miniCRAN.R  || exit # add the VE (and local) packages we just built to miniCRAN and ve-lib
Rscript setup-sources.R      || exit # copy the modules and VEGUI to the install/runtime staging area
bash build-installers.sh     || exit # these also land in a web-ready location

# Website is currently set up as a clone of my git repository, so only the miniCRAN gets rsync'ed
# bash publish-installers.R # Loads the "R" directory out to the website
