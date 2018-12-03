# Build the external packages (namedCapture)
# Use 'state-dependencies.R' to set up the required packages and VE directories.

# Intent here is to pick up packages installed from github.  Those should be cloned
# as submodules, ideally in the VisionEval tree, not here in the installer - if they
# are in VisionEval, we can just treat them as any other package though might want to
# skip tests.  Currenly only have one of those (namedCapture).

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

load("all-dependencies.RData")
if ( nrow(pkgs.external)> 0 ) {
	cat("Building external packages (source)\n")

	require(tools) # for write_PACKAGES below
    if (!suppressWarnings(require(devtools))) {
        install.packages("devtools",repos=CRAN.mirror)
    }

	# Where to put the built results (these should exist after build-repository.R)
	built.path.src <- contrib.url(ve.repository,type="source")

	# External packages to build (possibly submodules)
	pkgs <- file.path(ve.install,pkgs.external[,"Path"],pkgs.external[,"Package"])

	pkg.dependencies <- as.character(pkgs.external[,"Package"])
	all.dependencies <- c( all.dependencies, pkg.dependencies)
	stated.dependencies <- c( stated.dependencies, pkg.dependencies )
	save(stated.dependencies,all.dependencies,file="all-dependencies.RData")

	cat("External Packages:\n")
	print(pkgs)

	# Build missing source packages
    num.built <- 0
	for (pkg in pkgs) {
		if ( ! module.exists(pkg, built.path.src) ) {
			devtools::build(pkg,path=built.path.src)
            num.built <- num.built+1
		}
	}
    if (num.built>0) {
        write_PACKAGES(contrib.url(ve.repository,type="source"),type="source")
        cat(sprintf("Done building %d external packages.\n", num.built))
    } else {
        cat("No external packages requiring build.\n")
    }
} else {
    cat("No external packages configured.\n")
}
write(paste(all.dependencies,collapse=" "),
      file=file.path(ve.repository,"dependencies.lst"))
