# This R source file sets the key locations required to build an installer.
# The key item is the root 

# Required: root directory of the VisionEval version described in VE-dependencies.csv
ve.root <- "/home/jeremy/Git-Repos/visioneval-rsg"

# Optional: location in which "built-packages", "miniCRAN" and "runtime" will be built
# Defaults to putting those packages in an "installer_YYMMDD_HHMM" folder in ve.install
# Explicit representation of default:
ve.output <- file.path(ve.install,"Install_Ubuntu")

