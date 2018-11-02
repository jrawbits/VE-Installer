# Build the namedCapture package
# Use 'state-dependencies.R' to set up the required packages and VE directories.

print(getwd())
load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

if ( nrow(pkgs.external)> 0 ) {
	cat("Building external packages\n")

	# Where to put the built results (these are not version controlled, so create if missing)
	dir.create( ve.built, showWarnings=FALSE )
	dir.create( built.path.src <- file.path(ve.built,"src"), showWarnings=FALSE )
	dir.create( built.path.binary <- file.path(ve.built,"bin"), showWarnings=FALSE )

	# External packages to build (possibly submodules)
	pkgs <- file.path(ve.install,pkgs.external[,"Path"],pkgs.external[,"Package"])

	# Always build as source packages
	for (pkg in pkgs) devtools::build(pkg,path=built.path.src)

	# Build as binary package if the developer platform is windows
	cat("source build\n")
	build.type <- .Platform$pkgType
	if ( build.type == "win.binary" ) {
		for (pkg in pkgs) devtools::build(pkg,path=built.path.binary,binary=TRUE)
	}
} else {
	cat("No external packages to build\n")
}

