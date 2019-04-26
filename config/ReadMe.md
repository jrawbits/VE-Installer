# VisionEval Installer Configuration

This folder contains configuration files that are used to build (and rebuild) versions of
VisionEval.  It is feasible to mix and match different code trees (e.g. pulling the framework
from one repository and the models plus modules from another).

This ReadMe.md file documents the structure of the configuration files.

The configuration files are YAML, consisting of Key: Value pairs.

The keys can be anything (The samples contain 'Name', 'Date' and 'Description' for example), but
only the following will be examined:

Roots
Components
Locations

The structure of these

## Roots ##

In the "Roots" key, each elements is a tag:directory pair, where the tag is a symbolic name
used to define sources and targets for other elements that are processed during the build.  The
directory is an absolute path on the machine that will run the build (in whatever local syntax,
Windows or Linux or Macintosh, is appropriate).

In general, to use a configuration file on a different machine or with a different VisionEval
source tree, it is enough just to change the directory part of each root pair to point to
the correct directory.

While no root tags are formally required, it is conventional at a minimum to set ve.root to
the folder containing the source code for VisionEval, and ve.output to the folder that will contain
the build artifacts.

In order to define Locations, at least one Root tag must be defined (see the Locations description
below.

A special root, ve.install, is always available and is set internally during the build process
to the parent directory from which the build was launched.

## Locations ##

The Locations key contains elements that are name:specification pairs identifying the output
folders for each of the build steps.  The following Locations are the only ones recognized,
and each must have a definition:

	- ve.dependencies
	- ve.repository
	- ve.runtime
	- ve.pkgs
	- ve.lib
	- ve.test

The specification for each Location is a sequence of key:value pairs.  At least two key:value pairs
must be defined:

	- root

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
