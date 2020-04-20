#!/bin/env bash

if [ ! "$(alias gitgo 2>/dev/null)" ]
then
	echo setting alias
	echo $(realpath $BASH_SOURCE)
	alias gitgo="source $(realpath $BASH_SOURCE)"
fi

unset VE_BRANCH

if [ -z "$1" ]
then
	echo Working Trees in \~/$GIT_PATH
	ls -cd $HOME/$GIT_PATH/VisionEval-dev*
else
	VE_BRANCH=$(ls -d $HOME/$GIT_PATH/VisionEval-dev-*$1* 2>&1)

	if [ -d "$VE_BRANCH" ]
	then
		cd $VE_BRANCH
	else
		VE_BRANCH=$(ls -d $HOME/$GIT_PATH/VisionEval-dev 2>&1)
		echo WARNING: using base branch for VisionEval-dev
		if [ -d "$VE_BRANCH" ]
		then
			cd $VE_BRANCH
		else
			echo Not Found: $VE_BRANCH
		fi
	fi
fi
