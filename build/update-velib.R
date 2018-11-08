# Script to update ve.lib with "late additions" (built packages)

load("dependencies.RData")
if ( !check.VE.environment() ) stop("Run state-dependencies.R to set up build environment")

sought.pkgs <- available.packages(repos=ve.repo.url)[,"Package"]
installed.pkgs <- installed.packages(lib.loc=ve.lib)[,"Package"]
new.pkgs <- setdiff(sought.pkgs,installed.pkgs)

if(length(new.pkgs)>0) {
    cat("---Still missing these packages:\n")
    print(sort(new.pkgs))
    cat("---Installing missing packages---\n")
    install.packages(
        new.pkgs,
        lib=ve.lib,
        repos=ve.repo.url,
        dependencies=c("Depends","Imports","LinkingTo")
    )
    cat("---Finished installing---\n")
} else {
    cat("All packages accounted for in ve-lib\n")
}
