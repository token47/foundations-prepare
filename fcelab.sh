#!/bin/bash

prog=${0##*/}

function install() {

	for layer in $INSTALL_LAYERS; do
		source ./layers/${layer}.sh
		layer_install
		unset layer_install
		unset layer_uninstall
	done

}

function uninstall() {

	for layer in $UNINSTALL_LAYERS; do
		source ./layers/${layer}.sh
		layer_uninstall
		unset layer_install
		unset layer_uninstall
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

