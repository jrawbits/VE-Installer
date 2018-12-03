#!/bin/bash

# This script examines its arguments and sets up the corresponding
# VisionEval run.

VERSPM_ROOT=/home/visioneval/models/VERSPM
VERPAT_ROOT=/home/visioneval/models/VERPAT
VERSPM_TEST=Test1
VERPAT_TEST=.
USERDATA=/Data

function diagnose {
	# Twiddle the comments to get a line-by-line explanation
	# of how the test models are selected and the data set up.
	/bin/echo $*
	# :
}

# Verify that user data directory is mounted
# User can use a different one by provided a full (container-centric) path
# as an argument to the model
function mountedUserData {
	[ -d "${USERDATA}" ]
}

function dataAvailable {
	TESTDATA="$1"
	diagnose "Testing for presence of /defs and /inputs in ${TESTDATA}. ls:"
	/bin/ls ${TESTDATA}
	diagnose "ls EOF"
	[ -n "${TESTDATA}" -a -d "${TESTDATA}/defs" -a -d "${TESTDATA}/inputs" ]
}

function setData {
	# Set DATA to the folder where the model will run
	# $1: the default parent data directory for this model
	# $2: the subdirectory of $1 containing the default test data for this model
	# $3: the user supplied second argument (dataset on which to run model)
	# This function does rudimentary checking for the presence of model inputs
	DEF_PARENT=$1
	DEF_SUBDIR=$2
	USR_OPTION=$3
	diagnose "Sorting out:"
	diagnose "DEF_PARENT: ${DEF_PARENT}"
	diagnose "DEF_SUBDIR: ${DEF_SUBDIR}"
	diagnose "USR_OPTION: ${USR_OPTION}"
	if [ -z "${USR_OPTION}" ]; then
		# User did not provide alternative location
		# Check if /Data is available and has data in it
		DATA="${USERDATA}"
		diagnose "No alternative data: Trying data in ${USERDATA}"
		dataAvailable "$DATA" && return 0
		diagnose "No data in ${USERDATA}"
		SOURCEDATA="${DEF_PARENT}/${DEF_SUBDIR}"
		diagnose "SOURCEDATA set to $SOURCEDATA"
		# Fall through
	else
		# User provided a dataset directory or tag
		if [ -d "${USR_OPTION}" ]; then
			# user provided a full path to available mount point for /Data
			diagnose "Trying data in mounted directory ${USR_OPTION}"
			DATA="${USR_OPTION}"
			dataAvailable "$DATA" && return 0
			diagnose "No data in mounted directory ${USR_OPTION}"
			SOURCEDATA="${DEF_PARENT}/${DEF_SUBDIR}"
			# Fall through
		else
			# user provided a tag (subdirectory of model root) for data
			# typically to select a test data set
			SOURCEDATA="${DEF_PARENT}/${USR_OPTION}"
			DATA=""
			diagnose "Trying test data from ${SOURCEDATA}"
			dataAvailable "${SOURCEDATA}" || return 1 # no data to copy
			diagnose "Test data is available"
			# Fall through
		fi
		# Now we have SOURCEDATA and perhaps DATA
		if [ -z "${DATA}" ]; then
			diagnose "Locating output data directory."
			if [ mountedUserData ]; then
				DATA=${USERDATA}
				diagnose "Using ${USERDATA} for output"
				if dataAvailable "${USERDATA}"; then
					DATA=mktemp -d -p ${DATA} -t ${USR_OPTION}_XXX
					diagnose "in subdirectory ${DATA}"
				fi
			else
				# Worst case, we'll just run the model inside the container
				# use 'docker cp' to recover it later
				diagnose "Running model with no external output"
				DATA=${SOURCEDATA}
			fi
		fi
	fi	

	# Backstop test - should already have $DATA and $SOURCEDATA
	[ -z "${DATA}" -o -z "${SOURCEDATA}" ] && return 1
	diagnose "Reconciling ${DATA} with ${SOURCEDATA}"

	# If the SOURCEDATA is not the same as DATA, copy it over
	# Intended to leave model results in user space
	[ "${DATA}" != "${SOURCEDATA}" ] && \
		(diagnose "Copying test data"; cp -R ${SOURCEDATA}/defs/ ${SOURCEDATA}/inputs/ ${DATA} )
	diagnose "Final contents of ${DATA}:"
	/bin/ls -C ${DATA}

	dataAvailable "${DATA}"
}

echo "Welcome to VisionEval!"
diagnose "Invoked as '$0' '$1' '$2'"

# Determine which command to run
case "$1" in
VERSPM)
	echo "Running VERSPM $2"
	MODEL=/home/visioneval/models/Run_VERSPM.R
	setData "${VERSPM_ROOT}" "${VERSPM_TEST}" "$2" ||
		{ echo "VERSPM: No data to operate on"; exec ./help; }
	;;
VERPAT)
	echo "Running VERPAT $2"
	MODEL=/home/visioneval/models/Run_VERPAT.R
	setData "${VERPAT_ROOT}" "${VERPAT_TEST}" "$2" ||
		{ echo "VERPAT: No data to operate on"; exec ./help; }
	;;
bash)
	# Also requires starting the container with 'docker run -it'
	# Otherwise it just exits immediately
	exec bash -
	;;
HELP|*)
	exec ./help
	;;
esac

# If we haven't departed to an interactive shell or the help file
# then go ahead and run the model in its data directory
if [ ! -z "${MODEL}" -a ! -z "${DATA}" ]
then
	# expect to run this from /home/visioneval in order to
	# pick up .Rprofile to require visioneval and .Renviron
	# to locate ve-lib
	diagnose "Starting in '$(pwd)'"
	diagnose "Running '${MODEL}' in '${DATA}' which contains:"
	ls "${DATA}"
	diagnose "Starting Rscript:"
	Rscript run_model.r ${MODEL} ${DATA}
else
	echo "Incomplete model '${MODEL}' or data '${DATA}'"
	exec ./help
fi
