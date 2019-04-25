#!/bin/true # this file is not supposed to be called directly

function layer_install() {

	cat <<-EOF | sudo tee /etc/netplan/47-fce-lab.yaml >/dev/null
	network:
	  bridges:
	    ${BRIDGE}:
	      addresses: [ $(IFS=,; echo "${IPADDR[*]}") ]
	EOF

	sudo netplan apply

}

function layer_uninstall() {

	sudo ip link set $BRIDGE down
	sudo ip link delete $BRIDGE type bridge

	sudo rm -f /etc/netplan/47-fce-lab.yaml
	sudo netplan apply

}

