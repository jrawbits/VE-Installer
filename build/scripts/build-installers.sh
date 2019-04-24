#/bin/bash

# This builds (and publishes) the .zip installers - they go straight
# into the www folder

# First the online installer, which will pull the R packages from the
# visioneval installation server

# Must be in "build" folder (parent of "scripts") to start
# Take advantage of shell variable and make variable syntax being identical

# Expecting the RTools version of "zip"
if [ $# -gt 0 ]; then
  VE_R_VERSION=$1
elif [ -z "${VE_R_VERSION}" ]; then
  echo "VE_R_VERSION is not available from environment or as first argument to script"
  exit 1
fi

OLD_R_VERSION=${VE_R_VERSION}
. ve-output.${VE_R_VERSION}.make # loads VE_OUTPUT, VE_RUNTIME, VE_PLATFORM
if [ "${OLD_R_VERSION}" != "${VE_R_VERSION}" ]; then
  # Technically this should be impossible since the interior VE_R_VERSION in ve-output
  # should be the same as what is encoded in its name; but you never know!
  echo "VE_R_VERSION provided ($OLD_R_VERSION) does not match built R version ($VE_R_VERSION)"
  exit 2
fi

VE_BASE="${VE_OUTPUT}/${VE_R_VERSION}/VE-Runtime-R${VE_R_VERSION}.zip"
VE_SOURCE="${VE_OUTPUT}/${VE_R_VERSION}/VE-installer-Source-R${VE_R_VERSION}.zip"
VE_BINARY="${VE_OUTPUT}/${VE_R_VERSION}/VE-installer-${VE_PLATFORM}-R${VE_R_VERSION}.zip"
RUNTIME_PATH="${VE_RUNTIME}"

[ -f "${VE_BASE}" ]   && rm "${VE_BASE}"
[ -f "${VE_SOURCE}" ] && rm "${VE_SOURCE}"
[ -f "${VE_BINARY}" ] && rm "${VE_BINARY}"

cd "${RUNTIME_PATH}"

echo "Building online installer: ${VE_BASE}"
pwd
zip --recurse-paths "${VE_BASE}" .

# Binary installer (for VE_PLATFORM i.e. where we're running the scripts)
if [ -d "${VE_LIB}" ]
then
    echo "Building ${VE_PLATFORM} installer: ${VE_BINARY}"
    cd ${VE_LIB}/..
    pwd
    zip --recurse-paths "--output-file=${VE_BINARY}" "${VE_BASE}" "$(basename ${VE_LIB})"
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
