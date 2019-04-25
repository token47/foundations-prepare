#!/bin/true # this file is not supposed to be called directly

function layer_install() {

	# just in case the proxy is already running...
	sudo systemctl stop squid || :

	# We need to install and configure squid, but we may need a proxy for that
	# Obvisouly we cannot use local squid because it's not installed yet so
	# we may have only two options, go directly or use the external one.
	# If an external one is configured, let's trust we really need it and use it.

	if [ "$PEER_PROXY" == "yes" ]; then

		sudo apt \
			-o "Acquire::http::Proxy"="http://${PEER_PROXY_ADDR}:${PEER_PROXY_PORT}" \
			-o "Acquire::https::Proxy"="http://${PEER_PROXY_ADDR}:${PEER_PROXY_PORT}" \
			update
		sudo apt \
			-o "Acquire::http::Proxy"="http://${PEER_PROXY_ADDR}:${PEER_PROXY_PORT}" \
			-o "Acquire::https::Proxy"="http://${PEER_PROXY_ADDR}:${PEER_PROXY_PORT}" \
			install -y squid
	
	else

		sudo apt update
		sudo apt install -y squid

	fi
	
	# this is the main config
	cat <<-EOF | sudo tee /etc/squid/squid.conf >/dev/null
	dns_v4_first on
	forwarded_for off
	http_port 3128
	http_port 8000
	cache_dir aufs /var/spool/squid 500000 16 256
	http_access allow localhost manager
	http_access deny manager
	http_access allow all
	http_reply_access allow all
	coredump_dir /var/spool/squid
	EOF

	if [ "$PEER_PROXY" == "yes" ]; then

		# and this is the extra config for forwarding to external proxy
		cat <<-EOF | sudo tee -a /etc/squid/squid.conf >/dev/null
		acl directaccess dstdomain $PEER_PROXY_IGNORE
		cache_peer $PEER_PROXY_ADDR parent $PEER_PROXY_PORT 0 no-query name=extproxy default
		cache_peer_access extproxy deny directaccess
		cache_peer_access extproxy allow all
		never_direct deny directaccess
		never_direct allow all
		EOF

	fi

	# initialize the cache dir
	sudo squid -z

	sudo systemctl start squid

}

function layer_uninstall() {

	sudo systemctl stop squid
	#rm -f /etc/squid/squid.conf
	#rm -rf /var/spool/squid/*
	sudo apt remove -y --autoremove squid

}

