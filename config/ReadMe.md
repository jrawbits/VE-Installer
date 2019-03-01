# VisionEval Installer Configuration

This folder contains VE-dependencies.csv and VE-config.R which provide pointers
to the VisionEval source tree which is to be installed, the list of dependencies
to load or build, and (optionally) the output folder into which the installable
VisionEval should be built.

The configuration files should be adjusted to conform to the structure of the
VisionEval that you would like to install.  Samples are provided for some of the
key active development trees.  At a minimum, you'll need to update the paths for
your own system.

VE-config.R provides definitions for these file locations:
	* `ve.root` (required, full path to the VisionEval that is to be installed)
	* `ve.output` (optional, full path to the directory in which VE installation will be built)

VE-dependencies.csv has the following structure:

	* Columns "Package","Type","Path"
		* Package is the name of the package (or object) to be assembled
		  according to "Type" (with optional parameter "Path")
	* Choices for "Type" are
		* "CRAN"
		* "BioConductor",
		* "install" (a package, such as namedCapture, located in the install tree)
		* "visioneval" (for visioneval packages)
		* "copy" (for visioneval source trees not in packages [models,VEGUI])
	* The path is a string interpreted as follows:
		* it is ignored for CRAN and BioConductor Types
		* relative to ve.install for "install" Type
		* relative to ve.root for "visioneval" or "copy" Type

If there is a dependency order among the VE modules (type "visioneval"), they must be
listed in VE-dependencies.csv in the order in which they will be built, but the types do
not need to be listed consecutiavely.

The "install" type is intended to handle GitHub packages.  To use this installer, they
must be cloned or downloaded into the `ve.install` tree (that's what the "external" folder
is for).  Those packages will be built into source and binary packages and inserted into
the local repository, ready for local installation.  See the example dependencies.
