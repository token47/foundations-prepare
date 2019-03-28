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


