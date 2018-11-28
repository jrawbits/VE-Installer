#!/bin/bash

# This script examines its arguments and sets up the corresponding
# VisionEval run.

VERSPM_TEST=/home/visioneval/models/VERSPM/Test1
VERPAT_TEST=/home/visioneval/models/VERPAT

# Do some minimal checking of the adequacy of the data directory
function setdata {
	if [ -z "$1" ]; then
		DATA="/Data"
	else
		DATA="/home/visioneval/models/VERSPM/$1"
	fi
	if [ -d "$DATA/defs" -o ! -d "$DATA/inputs" ]; then
		echo "No model definition or inputs found in '${DATA}'"
		DATA="$2"
		echo "Using '${DATA}'"
	fi
}

# Determine which command to run
case "$1" in
VERSPM)
	MODEL=/home/visioneval/models/Run_VERSPM.R
	setdata "$2" "${VERSPM_TEST}"
	;;
VERPAT)
	MODEL=/home/visioneval/models/Run_VERPAT.R
	setdata "$2" "${VERPAT_TEST}"
	;;
bash)
	# Also requires starting the container with -it
	# Or attaching a tty to it later...
	exec bash -
	;;
HELP|*)
	exec ./help
	;;
esac

# If we haven't departed to an interactive shell or help file
# then go ahead and run the model in its data directory
if [ ! -z "${MODEL}" -a ! -z "${DATA}" ]
then
	# expect to run this from /home/visioneval in order to
	# pick up .Rprofile to require visioneval and .Renviron
	# to locate ve-lib
	Rscript run_model.r ${MODEL} ${DATA}
else
	echo "Incomplete '${MODEL}' or '${DATA}'"
	exec ./help
	;;
fi
