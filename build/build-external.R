# Build the external packages (namedCapture)
# Use 'state-dependencies.R' to set up the required packages and VE directories.

# Intent here is to pick up packages installed from github.  Those should be cloned
# as submodules, ideally in the VisionEval tree, not here in the installer - if they
# are in VisionEval, we can just treat them as any other package though might want to
# skip tests.  Currenly only have one of those (namedCapture).

print(getwd())
load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

if (!suppressWarnings(require(devtools))) {
	install.packages("devtools",repos=CRAN.mirror)
}

if ( nrow(pkgs.external)> 0 ) {
	cat("Building external packages\n")

	# Where to put the built results (these should exist after build-miniCRAN.R)
	built.path.src <- contrib.url(ve.miniCRAN,type="source")
	built.path.binary <- contrib.url(ve.miniCRAN,type="win.binary")

	# External packages to build (possibly submodules)
	pkgs <- file.path(ve.install,pkgs.external[,"Path"],pkgs.external[,"Package"])

	# Always build as source packages
	for (pkg in pkgs) {
		if ( ! module.exists(pkg, built.path.src) ) {
			devtools::build(pkg,path=built.path.src)
		}
	}

	# Build as binary package if the developer platform is windows
	# May need earlier externals as dependencies
	# TODO: automate examination of external package dependencies in build-miniCRAN.R
	# TODO: workaround for now is to ensure those dependencies are included in VE-dependencies.csv

	cat("source build\n")
	build.type <- .Platform$pkgType
	if ( build.type == "win.binary" ) {
		if (!suppressWarnings(require(withr))) {
			install.packages("withr",repos=CRAN.mirror)
		}
		with_temp_libpaths( action="prefix" , {
			for (pkg in pkgs) {
				if ( ! module.exists(pkg, built.path.binary) ) {
					built.package <- devtools::build(pkg,path=built.path.binary,binary=TRUE)
				} else {
					built.package <- file.path(built.path.binary,module.path(pkg,built.path.binary))
				}
				install.packages(built.package,repos=NULL) # so they will be available for later modules
			}
		} )
	}
} else {
	cat("No external packages to build\n")
}
