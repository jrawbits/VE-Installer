# Build the external packages (namedCapture)
# Use 'state-dependencies.R' to set up the required packages and VE directories.

# Intent here is to pick up packages installed from github.  Those should be cloned
# as submodules, ideally in the VisionEval tree, not here in the installer - if they
# are in VisionEval, we can just treat them as any other package though might want to
# skip tests.  Currenly only have one of those (namedCapture).

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

if (!suppressWarnings(require(devtools))) {
	install.packages("devtools",repos=CRAN.mirror)
}

if ( nrow(pkgs.external)> 0 ) {
	cat("Building external packages (binary)\n")

	require(tools)

	.libPaths( c(ve.lib,.libPaths()) ) # push runtime library onto path stack

	# Where to put the built results (these should exist after build-repository.R)
	built.path.binary <- contrib.url(ve.repository,type="win.binary")

	# External packages to build (possibly submodules)
	pkgs <- file.path(ve.install,pkgs.external[,"Path"],pkgs.external[,"Package"])

	build.type <- .Platform$pkgType
	if ( build.type == "win.binary" ) {
#		if (!suppressWarnings(require(withr))) {
#			install.packages("withr",repos=CRAN.mirror)
#		}
		for (pkg in pkgs) {
			if ( ! module.exists(pkg, built.path.binary) ) {
				built.package <- devtools::build(pkg,path=built.path.binary,binary=TRUE)
			} else {
				built.package <- file.path(built.path.binary,module.path(pkg,built.path.binary))
			}
			install.packages(built.package,repos=NULL,lib=ve.lib) # so they will be available for later modules
		}
		write_PACKAGES(built.path.binary,type="win.binary")
	} else {
		# install source package in whatever binary form works for the local environment
		for (pkg in pkgs) {
			install.packages(pkg,repos=NULL,lib=ve.lib,type="source")
		}
    cat("Done installing external binary packages.\n")
	}
} else {
	cat("No external packages to build (binary)\n")
}
