#/bin/bash

# This builds (and publishes) the .zip installers - they go straight
# into the www folder

# First the online installer, which will pull the R packages from the
# visioneval installation server

# Must be in "build" folder (parent of "scripts") to start
# Take advantage of shell variable and make variable syntax being identical

# Expecting the RTools version of "zip"

. ve-output.make # loads VE_OUTPUT, VE_INSTALLER, VE_PLATFORM
# Note that VE_R_VERSION is exported when this script is run from make
# By hand, do this:
# VE_R_VERSION=3.5.1 bash build-installers.sh
# Could use
#   VE_RUNTIME
#   VE_PKGS (source repository)
#   VE_LIB

VE_BASE="${VE_OUTPUT}/VE-Runtime.zip"
VE_SOURCE="${VE_OUTPUT}/VE-installer-Source-R${VE_R_VERSION}.zip"
VE_BINARY="${VE_OUTPUT}/VE-installer-${VE_PLATFORM}-R${VE_R_VERSION}.zip"
RUNTIME_PATH="${VE_RUNTIME}"

[ -f "${VE_ONLINE}" ] && rm "${VE_ONLINE}"
[ -f "${VE_BINARY}" ] && rm "${VE_BINARY}"

cd "${RUNTIME_PATH}"

echo "Building online installer: ${VE_BASE}"
pwd
zip --recurse-paths "${VE_BASE}" .

# Windows installer
if [ -d "${VE_LIB}" ]
then
    echo "Building Windows installer: ${VE_BINARY}"
    cd ${VE_LIB}/..
    pwd
    zip --recurse-paths "--output-file=${VE_BINARY}" "${VE_BASE}" "$(basename ${VE_LIB})/${VE_R_VERSION}"
fi

# Source installer
if [ -d "${VE_PKGS}" ]
then
    echo "Building Source installer: ${VE_SOURCE}"
    cd ${VE_PKGS}/..
    pwd
    zip --recurse-paths "--output-file=${VE_SOURCE}" "${VE_BASE}" "$(basename ${VE_PKGS})"
fi

echo "Done building installers."
