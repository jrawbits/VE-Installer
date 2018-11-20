Documentation of Build Process

0. Configure build
    * Edit VE-config.R (VE source tree, optional output directory name)
    * Edit VE-dependencies.csv (based on VE source tree needs)
    * Run state-dependencies.R (creates build/dependencies.RData)
1. Build Dependency Repository
    * Run build-repository.R
    * Retrieves CRAN and BioConductor packages (source and binary)
2. Build Source Packages
    * Run build-external-src.R (builds external source packages)
    * Run build-packages-src.R (builds VisionEval source packages)
    * Packages are built directly into the source repository
    * R PACKAGES file is updated
3. Set up sources
    * Run setup-sources.R (copies boilperplate to runtime folder)
4. Build Binary Packages (optional)
    * Run install-velib.R (constructs binary dependency library, needed for binary build)
    * Run build-external-bin.R
    * Run build-packages-bin.R
5. Make installers
    * Run build-installers.sh (constructs online installer, offline if available)
6. Make docker image
    * Run build-docker.sh (constructs VE docker image)
