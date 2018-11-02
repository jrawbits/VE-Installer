The "supply" folder contains R scripts and resources necessary to
build the packages necessary to install VisionEval.

Prerequisites include R and a suitable development environment.
You should install RTools if you're planning to build Windows binaries.
You will also need devtools and miniCRAN, plus dependencies.  If you're
planning to build from source on Windows you should expect to download a
bunch of supporting libraries.  On Ubuntu 16.04, installing the following
will be needed (plus X11 and a few other odds and ends - watch for errors
in the installation; use the 'rebuld-ve-lib.R' script to keep retrying
the build.

    To build "cairo" (used for nice image rendering):
    sudo apt-get install libcairo2-dev
    (Reportedly, you also need libxt-dev, which I already had)

    To build "V8" (used for who knows what):
    sudo apt-get libv8-dev

The following operations are performed (from a clone of the repository
on your local machine).  The result will be binary installers, plus
a web-accessible repository of all necessary VisionEval packages.

0. Development Environment for the "build" operation (build installer)
	* Edit .RProfile to identify ve.root (parent of "install")
1. Build VisionEval packages (source and, if running on Windows, binaries)
	* Run R script: build-packages.R
	* Output from this step is placed into the "built-packages" subfolder here (src and bin)
	* Packages are optionally checked (R CMD check) and then built
	* The built packages are used to populate the miniCRAN (next step)
2. Build the namedCapture package from Github
	* Used only - and probably gratuitously - in VEGUI)
	* Run bash script in "install/external" to build: buildNamedCapture.sh
	* Output packages are added to the built VE packages (source, binary)


Documentation lags.  Check one-stop-build.sh for almost-working directions...
