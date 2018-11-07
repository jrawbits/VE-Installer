# This R source file sets the key locations required to build an installer.
# The key item is the root 

# Required: root directory of the VisionEval version described in VE-dependencies.csv
ve.root <- "c:\\users\\jeremy.DESKTOP-OLMEAON\\Documents\\Git-Repos\\VisionEval-JR"

# Optional: location in which "built-packages", "miniCRAN" and "runtime" will be built
# Defaults to putting those packages in an "installer_YYMMDD_HHMM" folder in ve.install
# Explicit representation of default:
# ve.output <- file.path(ve.install,paste("installer",format(Sys.time(),"%y%m%d"),sep="_"))

