#!/bin/bash

# Simplified driver for make 

# Export VE_R_VERSION as an environment variable (works directly for make!)
# or provide an R Version like 3.5.1 as the first argument

# If you want to provide additional make objects or variables, you must
# specify the first argument as VE_R_VERSION (environment will still take
# precedence).  All remaining arguments are passed to "make"

VE_R_VERSION=${1:-${VE_R_VERSION:-3.5.3}}
shift
export VE_R_VERSION # overriding whatever may have been in the environment
make "$@"
