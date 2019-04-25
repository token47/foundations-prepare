#!/bin/bash

set -e

self_prog="$(basename "$0")"
self_dir="$(dirname "$0")"

source ${self_dir}/config.inc.sh
source ${self_dir}/lib/utils.inc.sh

function install() {

	for layer in "${INSTALL_LAYERS[@]}"; do
		layer_banner action=install layer="$layer"
		# we want a subshell so that "source" can have a forgettable scope
		(
		source ./layers/layer-${layer}.sh
		layer_install
		)
	done

}

function uninstall() {

	for layer in ${UNINSTALL_LAYERS[@]}; do
		layer_banner action=uninstall layer="$layer"
		(
		source ./layers/layer-${layer}.sh
		layer_uninstall
		)
	done

}

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
	exit 0
else
	usage
	exit 1
fi

