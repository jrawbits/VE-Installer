#!env bash

# Helper script. Run one time as "source config/config.sh"
# Afterwards, from VE-Installer root, you can use "config dev"
#   to pick and set VE_CONFIG for your build
# It will pick out the first matching VE-config*.yml file
# To permanently add the alias, do alias config >> ~/.profile

alias config="source $(realpath $BASH_SOURCE)"
if [ -z "$1" ] 
then
	echo Available configurations:
	ls -x config/VE-config-*.yml
else
	CONFIG_MATCH=$(ls config/VE-config-*$1*.yml | cut -d " " -f1)
	if [ -n "${CONFIG_MATCH}" ]
	then
		echo VE_CONFIG=${CONFIG_MATCH}
		export VE_CONFIG=${CONFIG_MATCH}
	else
		unset VE_CONFIG
		echo VE_CONFIG not set: ${CONFIG_MATCH}
	fi
fi
