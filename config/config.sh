#!env bash

# Helper script. Run one time as "source config/config.sh"
# Afterwards, from VE-Installer root, you can use "config dev"
#   to pick and set VE_CONFIG for your build
# It will pick out the first matching VE-config*.yml file
# To permanently add the alias, do alias config >> ~/.profile

if [ ! "$(alias config 2>/dev/null)" ]
then
    if [[ $SHELL == *"zsh"* ]]
    then
      echo setting zsh alias # for Macintosh default shell
      BASH_SOURCE="${(%):-%N}"
      realpath() {
        OURPWD=$PWD
        cd "$(dirname "$1")"
        LINK=$(readlink "$(basename "$1")")
        while [ "$LINK" ]; do
          cd "$(dirname "$LINK")"
          LINK=$(readlink "$(basename "$1")")
        done
        REALPATH="$PWD/$(basename "$1")"
        cd "$OURPWD"
        echo "$REALPATH"
      }          
    fi
    THE_SCRIPT=$(realpath $BASH_SOURCE)
    echo "${THE_SCRIPT}"
    alias config="source \"${THE_SCRIPT}\""
fi
VE_INST_ROOT=$(dirname $(dirname $BASH_SOURCE))

if [ -z "$1" ] 
then
    [ -n "$VE_CONFIG" ] && echo "Selected: $(basename ${VE_CONFIG})"
    echo Available configurations:
    ls -x ${VE_INST_ROOT}/config/VE-config-*.yml
else
    CONFIG_MATCH=$(ls $VE_INST_ROOT/config/VE-config-*$1*.yml 2>/dev/null)
    CONFIG_MATCH=$(echo $CONFIG_MATCH | cut -d " " -f1)
    if [ -n "${CONFIG_MATCH}" ]
    then
        echo VE_CONFIG=${CONFIG_MATCH}
        export VE_CONFIG=${CONFIG_MATCH}
        cd $(dirname $(dirname $VE_CONFIG))
    else
        unset VE_CONFIG
        echo No configuration for $1
        cd $VE_INST_ROOT
    fi
fi
if [ -n "$2" ]
then
    export VE_R_VERSION=$2
    echo VE_R_VERSION=${VE_R_VERSION}
else
    echo VE_R_VERSION=${VE_R_VERSION:-default}
fi
unset VE_INST_ROOT VE_CONFIG_FINDER
