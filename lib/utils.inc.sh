#!/bin/true
#
# This file is to be included from other scripts
#

# logging commands and their output
# $1 is a command to execute
function logit() {
	(
	echo "***************************************************************************"
	date
	echo "${1}"
	eval "${1}"
	uptime
	echo
	) >> $LOG 2>&1
}


function info() {
        echo -n "${1}"
}


function ok() {
        printf "${GREEN}OK${NC}\n"
}

function usage ()
{
        echo "Usage: $prog [-i|-u] [-v] [-h]"
	exit 0
}

function banner() {

	local "$@"

	echo
	echo "######################################################################"
	echo "### Layer: $layer  Action: $action"
	echo


}
