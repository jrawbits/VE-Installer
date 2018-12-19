#!/bin/bash
# You'll need to set a path to the RSYNC executable (e.g. in Rtools;
# see below on setting up suitable parameters).

# Requires $WWW_SSH_PORT (use 22 if you have no idea)
# $VE_WEBSITE as the location to which to publish the files, and it should include the
# user, for example:
# export VE_WEBSITE=<USER>@<HOST>:/home/<USER>/www
# If you're using Git for Windows and the Rtools rsync, double the slash after the
# VE_WEBSITE colon, like this:
# export VE_WEBSITE=<USER>@<HOST>://home/<USER>/www

# you can put the credentials in the .gitignore'd website.credentials file
# in Shell variable format,
# or if that file is not there, it will use settings from your
# .bashrc or .profile (or even manually when you start make).

[ -f website.credentials ] && . website.credentials

VE_OUTPUT=$(Rscript -e "load('dependencies.RData'); cat(ve.output)")
cd ${VE_OUTPUT}
VE_INSTALLER="VE-installer.zip"
VE_WINDOWS="VE-installer-windows-R3.5.1.zip"
"${RSYNC}" -avz -e "ssh -p ${WWW_SSH_PORT}" "${VE_INSTALLER}" "${VE_WINDOWS}" ${VE_WEBSITE}/
"${RSYNC}" -ravzP --delete -e "ssh -p ${WWW_SSH_PORT}" pkg-repository/src/ ${VE_WEBSITE}/R/src/
"${RSYNC}" -ravzP --delete -e "ssh -p ${WWW_SSH_PORT}" pkg-repository/bin/ ${VE_WEBSITE}/R/bin/
