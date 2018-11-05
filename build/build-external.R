# Build the external packages (namedCapture)
# Use 'state-dependencies.R' to set up the required packages and VE directories.

# Intent here is to pick up packages installed from github.  Those should be cloned
# as submodules, ideally in the VisionEval tree, not here in the installer - if they
# are in VisionEval, we can just treat them as any other package though might want to
# skip tests.  Currenly only have one of those (namedCapture).

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
	for (pkg in pkgs) {
		if ( ! module.exists(pkg, built.path.src) ) {
			devtools::build(pkg,path=built.path.src)
		}
	}

	# Build as binary package if the developer platform is windows
	cat("source build\n")
	build.type <- .Platform$pkgType
	if ( build.type == "win.binary" ) {
		for (pkg in pkgs) {
			if ( ! module.exists(pkg, built.path.binary) ) {
				devtools::build(pkg,path=built.path.binary,binary=TRUE)
			}
		}
	}
} else {
	cat("No external packages to build\n")
}

