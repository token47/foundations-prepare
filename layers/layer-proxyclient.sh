#!/bin/true # this file is not supposed to be called directly

function layer_install() {

	[ "$ENV_PROXY" != "yes" ] && return 0

	# if environment is already set, presume all config is ok and exit
	grep -q "# fce-lab tool$" /etc/environment && return 0

	cat <<-EOF | sudo tee -a /etc/environment >/dev/null
	http_proxy="${ENV_PROXY_URI}"  # fce-lab tool
	https_proxy="${ENV_PROXY_URI}"  # fce-lab tool
	no_proxy="localhost,127.0.0.1"  # fce-lab tool
	EOF

	# restart snapd so it can re-load environment and use new proxy settings
	sudo systemctl restart snapd

	# set proxy on apt
	cat <<-EOF | sudo tee /etc/apt/apt.conf.d/fce-lab-proxy.conf >/dev/null
	Acquire::http::Proxy "${ENV_PROXY_URI}";
	Acquire::https::Proxy "${ENV_PROXY_URI}";
	EOF

}

function layer_uninstall() {

	# remove all
	sudo ex -sc "$(echo -en ":g/# fce-lab tool$/d\nx")" /etc/environment
	sudo rm -f /etc/apt/apt.conf.d/fce-lab-proxy.conf
	sudo systemctl restart snapd

}

