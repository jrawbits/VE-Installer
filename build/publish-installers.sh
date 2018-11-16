#!/bin/bash
# Getting rsync for Git for Windows Bash:
# https://serverfault.com/questions/310337/using-rsync-from-msysgit-for-binary-files
# The Rtools version of rsync doesn't cooeperate nicely with Git for Windows bash

# Requires $WWW_SSH_PORT (use 22 if you have no idea)
# $VE_WEBSITE as the location to which to publish the files, and it should include the
# user, for example:
# export VE_WEBSITE=<USER>@<HOST>:/home/<USER>/www

# VE_OUTPUT=$(Rscript -e "load('dependencies.RData'); cat(ve.output)" | sed -e 's/c:\\/\/c\//I')
VE_OUTPUT=$(Rscript -e "load('dependencies.RData'); cat(ve.output)")
cd ${VE_OUTPUT}
VE_INSTALLER="VE-installer.zip"
VE_WINDOWS="VE-installer-windows-R3.5.1.zip"
rsync -avz -e "ssh -p ${WWW_SSH_PORT}" "${VE_INSTALLER}" "${VE_WINDOWS}" ${VE_WEBSITE}/
rsync -ravzP --delete -e "ssh -p ${WWW_SSH_PORT}" pkg-repository/src/ ${VE_WEBSITE}/R/src/
rsync -ravzP --delete -e "ssh -p ${WWW_SSH_PORT}" pkg-repository/bin/ ${VE_WEBSITE}/R/bin/
