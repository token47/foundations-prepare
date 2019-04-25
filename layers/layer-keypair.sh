#!/bin/true # this file is not supposed to be called directly

function layer_install() {

	# we never overwrite the key after once created
	[ -f ~/.ssh/rsa_id ] && exit

	echo 'y' | ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''

}

function layer_uninstall() {

	# we do not erase the key when uninstalling
	:

}

