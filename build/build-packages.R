# Build and (optionally) Check the VE packages

# Very important to set up VE-dependencies.csv correctly (see state-dependencies.R)
# If there is a dependency order among the VE modules, they must be listed in VE-dependencies.csv
# in the order in which they will be built

# We're not going to rebuild from source if the binary is outdated and compilation is required
# (stringi as of 10/9 does not build correctly...)
options(install.packages.compile.from.source="never")

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

# Push the VE required packages onto .libPaths (previously installed in install-velib.R)
if ( interactive() ) oldLibPaths <- .libPaths()
.libPaths( ve.lib ) # push runtime library onto path stack

# NOTE: developers are discouraged from putting any/too many depedencies into their
# development environment, especially when adding dependencies - those should always
# find their way (first) into the miniCRAN (or be installed into ve.lib)

# Where to find the package sources (in the VisionEval repository)
package.paths <- file.path(ve.root,pkgs.visioneval[,"Path"],pkgs.visioneval[,"Package"])

# Where to put the built results (these are not version controlled, so create if missing)
dir.create( ve.built, showWarnings=FALSE )
dir.create( built.path.src <- file.path(ve.built,"src"), showWarnings=FALSE )
dir.create( built.path.binary <- file.path(ve.built,"bin"), showWarnings=FALSE )

# Check the packages (default not to in the full script, but ask if interactive)
if (interactive() && askYesNo("Comprehensively check packages (Warning: PAINFUL)",default=FALSE)) {
	for (module in package.paths) devtools::check(module)
}

# Always build the framework and modules as source packages (though ask if interactive)
if ( ! interactive() || askYesNo("Build source packages)",default=TRUE)) {
	for (module in package.paths) {
		if ( ! module.exists(module, built.path.src) ) {
			devtools::build(module,path=built.path.src)
		}
	}
}

# Build the framework and modules as binary packages if the local system wants win.binary (ask if interactive)
build.type <- .Platform$pkgType
if ( build.type == "win.binary" && ( ! interactive() ||  askYesNo("Build binary packages (Warning: SLOW)",default=FALSE)) ) {
	if (!suppressWarnings(require(withr))) {
		install.packages("miniCRAN",repos=CRAN.mirror)
	}
	with_temp_libpaths( action="prefix" , {
		for (module in package.paths) {
			if ( ! module.exists(module, built.path.binary) ) {
				built.package <- devtools::build(module,path=built.path.binary,binary=TRUE)
			} else {
				built.package <- file.path(built.path.binary,module.path(module,built.path.binary))
			}
			install.packages(built.package,repos=NULL) # so they will be available for later modules
		}
	})
}

# Restore .libPaths (only needed in interactive environment)
if ( interactive() ) .libPaths(oldLibPaths)
