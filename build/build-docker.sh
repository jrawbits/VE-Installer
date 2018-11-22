#!/bin/bash

VE_DOCKER=$(readlink -f ../docker)
DOCKERFILE=${VE_DOCKER}/Dockerfile
VE_OUTPUT=$(Rscript -e "load('dependencies.RData'); cat(ve.output)")
cd ${VE_OUTPUT}

cp ${VE_DOCKER}/.dockerignore ${VE_OUTPUT}
cp -a ${VE_DOCKER}/home/. ${VE_OUTPUT}/home/

docker build -f ${DOCKERFILE} -t visioneval .
