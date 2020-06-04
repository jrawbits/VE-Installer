# Source at the top of scripts to ensure runtime configuration is loaded
# Source this file at the beginning of each build step module

ve.runtime.config <- Sys.getenv("VE_RUNTIME_CONFIG",
  paste(file.path(getwd(),"logs/dependencies"),paste(R.version[c("major","minor")],collapse="."),"RData",sep="."))
if ( ! file.exists(normalizePath(ve.runtime.config,winslash="/")) ) {
  stop("Missing VE_RUNTIME_CONFIG ",ve.runtime.config,
       "\nRun build-config.R to set up build environment")
}
load(ve.runtime.config)
if ( ! checkVEEnvironment() ) {
  stop("Run build-config.R to set up build environment")
}
if ( ! exists("ve.build.type") ) {
  stop("Obsolete configuration: Run build-config.R to set up build environment")
}
