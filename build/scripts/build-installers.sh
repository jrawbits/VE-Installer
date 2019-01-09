#/bin/bash

# This builds (and publishes) the .zip installers - they go straight
# into the www folder

# First the online installer, which will pull the R packages from the
# visioneval installation server

# Must be in "build" folder (parent of "scripts") to start
# Take advantage of shell variable and make variable syntax being identical

# Expecting the RTools version of "zip"

. ve-output.make # loads VE_OUTPUT, VE_INSTALLER, VE_ROOT, VE_PLATFORM, VE_R_VERSION

VE_ONLINE="${VE_OUTPUT}/VE-installer.zip"
VE_BINARY="${VE_OUTPUT}/VE-installer-${VE_PLATFORM}-R${VE_R_VERSION}.zip"
RUNTIME_PATH="${VE_OUTPUT}/runtime"

cd "${RUNTIME_PATH}"

[ -f "${VE_ONLINE}" ] && rm "${VE_ONLINE}"
[ -f "${VE_BINARY}" ] && rm "${VE_BINARY}"

echo "Building online installer: ${VE_ONLINE}"
zip --recurse-paths "${VE_ONLINE}" .

# Windows installer
cd "${VE_OUTPUT}"
if [ -d ve-lib ] && [ ! -z "$(ls -A ve-lib)" ]
then
    echo "Building offline (Windows) installer: ${VE_BINARY}"
    zip --recurse-paths "--output-file=${VE_BINARY}" "${VE_ONLINE}" ve-lib
fi

echo "Done building installers."
