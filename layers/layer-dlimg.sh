#!/bin/true # this file is not supposed to be called directly

function layer_install() {

	[ -d ~/images ] || mkdir ~/images
	cd ~/images

	# no need to worry about proxy because it's on the environment (if needed)
	wget -t3 -c "$IMAGE_LOCATION/$IMAGE_NAME"

}

function layer_uninstall() {

	rm -rf ~/images

}

