# Build and (optionally) Check the VE packages

# Very important to set up VE-dependencies.csv correctly (see state-dependencies.R)
# If there is a dependency order among the VE modules, they must be listed in VE-dependencies.csv
# in the order in which they will be built

# We're not going to rebuild from source if the binary is outdated and compilation is required
# (stringi as of 10/9 does not build correctly...)
options(install.packages.compile.from.source="never")

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

require(tools)
require(devtools)
require(rstudioapi)

# Reach for ve.lib first.
# Could use this hack to squeeze out local libraries, but we still need devtools...
# https://stackoverflow.com/questions/36873307/how-to-change-and-remove-default-library-location
#   old.lib.loc <- get(".lib.loc",envir=environment(.libPaths))
#   assign(".lib.loc",c(ve.lib,.Library),envir=environment(.libPaths))

.libPaths( ve.lib ) # push runtime library onto path stack

# NOTE: developers are discouraged from putting any/too many depedencies into their
# development environment, especially when adding dependencies - those should always
# find their way (first) into the miniCRAN (or be installed into ve.lib)

# Where to find the package sources (in the VisionEval repository)

package.paths <- file.path(ve.root,pkgs.visioneval[,"Path"],pkgs.visioneval[,"Package"])

# Where to put the built results (these should exist after build-miniCRAN.R)

built.path.src <- contrib.url(ve.repository,type="source")
built.path.binary <- contrib.url(ve.repository,type="win.binary")

# Put the following in a separate build step for checking the packages
# # Check the packages (default not to in the full script, but ask if interactive)
# if (interactive() && askYesNo("Comprehensively check packages (Warning: PAINFUL)",default=FALSE)) {
# 	for (module in package.paths) devtools::check(module)
# }

for (module in package.paths) {
	if ( ! module.exists(module, built.path.src) ) {
		devtools::build(module,path=built.path.src)
	}
}
write_PACKAGES(contrib.url(ve.repository,type="source"),type="source")

# Build the framework and modules as binary packages if the local system wants win.binary
build.type <- .Platform$pkgType
if ( build.type == "win.binary" ) {
	if (!suppressWarnings(require(withr))) {
		install.packages("withr",repos=CRAN.mirror)
	}
	for (module in package.paths) {
		if ( ! module.exists(module, built.path.binary) ) {
			built.package <- devtools::build(module,path=built.path.binary,binary=TRUE)
		} else {
			built.package <- file.path(built.path.binary,module.path(module,built.path.binary))
		}
		install.packages(built.package,repos=NULL,lib=ve.lib) # so they will be available for later modules
	}
	write_PACKAGES(contrib.url(ve.repository,type="win.binary"),type="win.binary")
} else {
	# install source package in whatever binary form works for the local environment
	for (module in package.paths) {
		install.packages(module.path(module,built.path.src),repos=NULL,lib=ve.lib,type="source")
	}
}
