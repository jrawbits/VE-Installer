Documentation of Build Process

See `build/Makefile` for the definitive instruction set.  Build.sh is up to
date except the `docker` build is only in the Makefile.

0. Configure build
    * Edit VE-config.R (VE source tree, optional output directory name)
    * Edit VE-dependencies.csv (based on VE source tree needs)
    * Run state-dependencies.R (creates build/dependencies.RData)
1. make repository
	* Makes the full source repository (dependencies, externals, packages)
    * Retrieves CRAN and BioConductor packages (source and binary)
	* Pulls down the Windows binaries
    * Run build-repository.R
    * Run build-external-src.R (builds external source packages)
    * Run build-packages-src.R (builds VisionEval source packages)
4. make binary
	* Makes binary packages
    * Run install-velib.R (constructs binary dependency library, needed for binary build)
    * Run build-external-bin.R
    * Run build-packages-bin.R
5. make installers
	* Makes installers (offline only unless make binary is done)
    * Run setup-sources.R (copies boilperplate to runtime folder)
    * Run build-installers.sh (constructs online installer, offline if available)
6. make docker
	* Makes a docker image from the Dockerfile and source
	* Expects Install_Modules_Only configuration
    * Makefile contains instructions
