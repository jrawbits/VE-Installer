#!env bash

# Helper script. Run one time as "source config/config.sh"
# Afterwards, from VE-Installer root, you can use "config dev"
#   to pick and set VE_CONFIG for your build
# It will pick out the first matching VE-config*.yml file
# To permanently add the alias, do alias config >> ~/.profile

if [ ! "$(alias config 2>/dev/null)" ]
then
	echo setting alias
	alias config="source $(realpath $BASH_SOURCE)"
	alias config
fi
VE_INST_ROOT=$(dirname $(dirname $BASH_SOURCE))

if [ -z "$1" ] 
then
	echo Available configurations:
	ls -x $VE_INST_ROOT/config/VE-config-*.yml
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
unset VE_INST_ROOT VE_CONFIG_FINDER
