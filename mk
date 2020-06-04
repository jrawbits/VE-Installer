#!/bin/bash

if [ -z "${VE_CONFIG}" ]
then
  echo "Config not set, using 'config/VE-config.yml'"
  export VE_CONFIG=config/VE-config.yml
fi
if [ -z "${VE_R_VERSION}" ]
then
  export VE_R_VERSION=4.0.0
fi

export VE_BRANCH=$(basename ${VE_CONFIG} | cut -d'.' -f 1 | cut -d'-' -f 2-3)
export VE_LOGS=logs/VE-${VE_R_VERSION}-${VE_BRANCH}
export VE_MAKEOUT=$(echo ${VE_LOGS} | sed 's/config-//')-make.out

echo VE_CONFIG=${VE_CONFIG}
echo VE_BRANCH=${VE_BRANCH}
echo VE_LOGS=${VE_LOGS}
echo VE_MAKEOUT=${VE_MAKEOUT}

echo Starting build for \'${VE_BRANCH}\'
nohup make >${VE_MAKEOUT} 2>&1 &
echo "tail -f ${VE_MAKEOUT}"


