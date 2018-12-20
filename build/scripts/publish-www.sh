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

[ -f ve-output.make ] || echo "Need to run state-dependencies.R"
. ve-output.make

cd ${VE_INSTALLER}/www/_site

# Obviously, you need to build the Jekyll _site first!
# Not deleting because we don't want to take out the pkg-repository or installers
"${RSYNC}" -rvazP -e "ssh -p ${WWW_SSH_PORT}" --exclude=src --exclude=bin --exclude=installers --delete ./ "${VE_WEBSITE}/"
