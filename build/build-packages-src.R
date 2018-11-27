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
if (!suppressWarnings(require(devtools))) {
	install.packages("devtools",repos=CRAN.mirror)
}
if (!suppressWarnings(require(knitr))) {
	install.packages("knitr",repos=CRAN.mirror)
}

# Reach for ve.lib first.
# Could use this hack to squeeze out local libraries, but we still need devtools...
# https://stackoverflow.com/questions/36873307/how-to-change-and-remove-default-library-location
#   old.lib.loc <- get(".lib.loc",envir=environment(.libPaths))
#   assign(".lib.loc",c(ve.lib,.Library),envir=environment(.libPaths))

# Where to find the package sources (in the VisionEval repository)

ve.packages <- pkgs.visioneval[,"Package"]
package.paths <- file.path(ve.root,pkgs.visioneval[,"Path"],ve.packages)

# Where to put the built results (these should exist after build-miniCRAN.R)

built.path.src <- contrib.url(ve.repository,type="source")

# Put the following in a separate build step for checking the packages
# # Check the packages (default not to in the full script, but ask if interactive)
# if (interactive() && askYesNo("Comprehensively check packages (Warning: PAINFUL)",default=FALSE)) {
# 	for (module in package.paths) devtools::check(module)
# }

num.built <- 0
for (module in package.paths) {
	if ( ! module.exists(module, built.path.src) ) {
		devtools::build(module,path=built.path.src)
        num.built <- num.built+1
	}
}
if (num.built>0) {
    write_PACKAGES(contrib.url(ve.repository,type="source"),type="source")
    cat(sprintf("Done building %d VisionEval packages.\n", num.built))
} else {
    cat("No VisionEval packages requiring build.\n")
}
write(paste(as.character(ve.packages),collapse=" "),
      file=file.path(ve.repository,"visioneval.lst"))

