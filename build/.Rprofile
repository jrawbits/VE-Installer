# Configuration for package build operation
# If you are starting build from a running R session (instead of a new one), just source this file
# Key item here is to make sure there's a writable repository for the required build tools:
#  devtools, miniCRAN.

local({r <- getOption("repos")
      r["CRAN"] <- "https://cloud.r-project.org"
      options(repos=r)})
this.R <- paste(R.version[c("major","minor")],collapse=".")
dev.lib <- file.path(getwd(),"dev-lib",this.R)
cat("dev-lib:",dev.lib,"\n")
.libPaths(c(dev.lib,.libPaths()))
cat(paste(.libPaths(),collapse="\n"),"\n",sep="")
