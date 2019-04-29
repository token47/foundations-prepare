#!/bin/bash

set -e

trap error_trap ERR

self_prog="$(basename "$0")"
self_dir="$(dirname "$0")"

source ${self_dir}/config.inc.sh
source ${self_dir}/layers/utils.inc.sh

function install() {

	for layer in "${INSTALL_LAYERS[@]}"; do
		banner action=install layer="$layer"
		# we want a subshell so that "source" can have a disposable scope
		(
		source ./layers/layer-${layer}.sh
		layer_install
		)
	done

}

function uninstall() {

	for layer in ${UNINSTALL_LAYERS[@]}; do
		banner action=uninstall layer="$layer"
		(
		source ./layers/layer-${layer}.sh
		layer_uninstall
		)
	done

}

function error_trap() {

	echo
	echo "An error has occurred. Instalation aborted. Please revise the logs."
	echo

}

if [ ${USER} != 'ubuntu' ]; then
	echo "Script must run under user ubuntu"
	exit 1
fi

mflag=false
while getopts "iuvh" opt
do
	case "$opt" in
	i) mflag=true; install ;;
	u) mflag=true; uninstall ;;
	v) VERBOSE=1 ;;
	h) usage; exit 1 ;;
	esac
done
shift $((OPTIND - 1))

if $mflag; then
	banner "Operation completed successfuly."
	exit 0
else
	usage
	exit 1
fi

