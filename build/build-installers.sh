#/bin/bash

# This builds (and publishes) the .zip installers - they go straight
# into the www folder

# First the online installer, which will pull the R packages from the
# visioneval installation server

# TODO: if you run this on something other than Windows, the "Windows" installer
# will actually be a source installer...  Could live with just changing the
# name of the installer zip file.

VE_INSTALLER=../www/VE-installer.zip
VE_WINDOWS=../www/VE-installer-windows-R3.5.1.zip
RUNTIME_PATH="../runtime" # change as necessary

cd ${RUNTIME_PATH}

[ -f ${VE_INSTALLER} ] && rm ${VE_INSTALLER}
[ -f ${VE_WINDOWS} ] && rm ${VE_WINDOWS}

zip --recurse-paths ${VE_INSTALLER} .Rprofile Install-VisionEval.bat Install-VisionEval.R RunVisionEval.R models vegui

# Windows installer
zip --recurse-paths --output-file=${VE_WINDOWS} ${VE_INSTALLER} ve-lib

# TODO; review the insanely huge number of dependencies and streamline
# them.  There's probably a lot of cruft that some careful thinking
# might be able to sidestep
