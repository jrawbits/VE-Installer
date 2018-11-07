#/bin/bash

# This builds (and publishes) the .zip installers - they go straight
# into the www folder

# First the online installer, which will pull the R packages from the
# visioneval installation server

# TODO: if you run this on something other than Windows, the "Windows" installer
# will actually be a source installer...  Could live with just changing the
# name of the installer zip file.

# TODO: Add Dockerfile / image construction

VE_OUTPUT=$(Rscript -e "load('dependencies.RData'); cat(ve.output)")
VE_INSTALLER=${VE_OUTPUT}/VE-installer.zip
VE_WINDOWS=${VE_OUTPUT}/VE-installer-windows-R3.5.1.zip
RUNTIME_PATH="${VE_OUTPUT}/runtime" # change as necessary

cd ${RUNTIME_PATH}

[ -f ${VE_INSTALLER} ] && rm ${VE_INSTALLER}
[ -f ${VE_WINDOWS} ] && rm ${VE_WINDOWS}

echo "Building online installer: ${VE_INSTALLER}"
zip --recurse-paths ${VE_INSTALLER} .Rprofile Install-VisionEval.bat Install-VisionEval.R RunVisionEval.R models vegui

# Windows installer
echo "Building offline (Windows) installer: ${VE_WINDOWS}"
cd ${VE_OUTPUT}
zip --recurse-paths --output-file=${VE_WINDOWS} ${VE_INSTALLER} ve-lib

echo "Done building installers."

# TODO; review the insanely huge number of dependencies and streamline
# them.  There's probably a lot of cruft that some careful thinking
# might be able to sidestep
