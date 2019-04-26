#!/bin/true # this file is not supposed to be called directly

function layer_install() {

	# check if rules are already in place and exit
	sudo iptables -L -n -v | grep -q "/\* fce-lab \*/" && return 0

	sudo iptables -t nat -A POSTROUTING -s ${IPADDR[0]} ! -d ${IPADDR[0]} \
		-m comment --comment "fce-lab" -j MASQUERADE
	sudo iptables -t filter -A INPUT -i $BRIDGE -m comment --comment "fce-lab" -j ACCEPT
	sudo iptables -t filter -A INPUT -i $BRIDGE -m comment --comment "fce-lab" -j ACCEPT
	sudo iptables -t filter -A FORWARD -o $BRIDGE -m comment --comment "fce-lab" -j ACCEPT
	sudo iptables -t filter -A FORWARD -i $BRIDGE -m comment --comment "fce-lab" -j ACCEPT

	sudo netfilter-persistent save
}

function layer_uninstall() {

	# check if no rules to remove, then exit
	sudo iptables -L -n -v | grep -q "/\* fce-lab \*/" || return 0

	sudo iptables -t nat -D POSTROUTING -s ${IPADDR[0]} ! -d ${IPADDR[0]} \
		-m comment --comment "fce-lab" -j MASQUERADE
	sudo iptables -t filter -D INPUT -i $BRIDGE -m comment --comment "fce-lab" -j ACCEPT
	sudo iptables -t filter -D INPUT -i $BRIDGE -m comment --comment "fce-lab" -j ACCEPT
	sudo iptables -t filter -D FORWARD -o $BRIDGE -m comment --comment "fce-lab" -j ACCEPT
	sudo iptables -t filter -D FORWARD -i $BRIDGE -m comment --comment "fce-lab" -j ACCEPT

	sudo netfilter-persistent save

}

