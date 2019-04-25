#!/bin/true # this file is not supposed to be called directly

function process_apt() {

	if [ "$action" == "install" ]; then
		sudo DEBIAN_FRONTEND=noninteractive apt install -y -q $pkg_list
	else
		sudo DEBIAN_FRONTEND=noninteractive apt remove -y -q --autoremove $pkg_list
	fi

}

function process_snap() {

	if [ "$action" == "install" ]; then
		if snap info $pkg | grep -q " stable: .* classic$"; then
			sudo snap install $pkg --classic
		else
			sudo snap install $pkg
		fi
	else
		snap remove $pkg
	fi
}

function do_action() {

	local "$@"
	local pkg
	local pkg_list=""

	for pkg in "${INSTALL_PACKAGES[@]}"; do

		if [[ "$pkg" =~ snap\: ]]; then
			pkg="${pkg##snap:}"
			process_snap
		else
			pkg_list="$pkg_list $pkg"
		fi

	done

	[ -n "$pkg_list" ] && process_apt

}


function layer_install() {

	do_action action=install

}

function layer_uninstall() {

	do_action action=uninstall

}

