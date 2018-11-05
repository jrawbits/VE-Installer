This folder contains VE-dependencies.csv and VE-config.R which contains pointers
to the VisionEval source tree which is to be installed.

The configuration files should be adjusted to conform to the structure of the
VisionEval that you would like to install.  Samples are provided for some of the
key active development trees.

VE-config.R provides definitions for these file locations:
ve.root (required, full path to the VisionEval that is to be installed)
ve.output (optional, full path to the directory in which VE installation will be built)

VE-dependencies.csv has the following structure:

#   Columns "Package","Type","Path"
#   Package is the name of the package (or object) to be assembled
#   according to "Type" (with optional parameter
#   Choices for "Type" are
#		"CRAN"
#		"BioConductor",
#		"install" (a package, such as namedCapture, located in the install tree)
#		"visioneval" (for the visioneval packages)
#       "copy" (for copying from the visioneval source trees [models,vegui])
#   The path is a path string unpacked as follows:
#       it is ignored for CRAN and BioConductor Types
#		relative to ve.install for "install" Type
#		relative to ve.root for "visioneval" or "copy" Type
# If there is a dependency order among the VE modules (type "visioneval"),
# they must be listed in VE-dependencies.csv in the order in which they
# will be built
