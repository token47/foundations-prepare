#!/bin/true # this script is not supposed to be run

# (c) Andre Ruiz 2019

# Ip address of the bridge on the host. The first ip is mandatory (it's the OAM ip). The
# others will be aliases on the same bridge to ease accessing openstack networks from the host
BRIDGE=maasbr0
IPADDR=(
	192.168.210.1/24
	10.0.1.1/24
	10.0.2.1/24
	10.0.3.1/24
	10.0.6.0/24
)

# whether to set up a local squid proxy service on this host
# my sugestion is to answer yes here, and consider this the main proxy of the environment
# then use this host as the maas proxy in master.yaml (and disable peer proxy)
# also, set all proxies for apt, juju and others in master.yaml to this one too
# this also helps keeping maas disk small (avoid proxy cache inside maas)
# it will be accessible at http://<this-host>:3128/ or http://<this-host>:8000/
LOCAL_PROXY_SERVER=yes # Values: yes/no

# whether to use an external proxy as a peer (forwarder) for the local squid proxy
# networks on the ignore list will be accessed directly (not forwarded)
# this will be ignored if you answered no on LOCAL_PROXY_SERVER
PEER_PROXY=yes # Values: yes/no
PEER_PROXY_ADDR="91.189.89.216" # attention: do not use http:// format
PEER_PROXY_PORT="3128"
PEER_PROXY_IGNORE="127.0.0.1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

# whether to put proxy variables on the environment of this host (/etc/environment)
# this will set http_proxy and https_proxy env vars on this host shells, also
# configure snap, apt and other apps to use the proxy
# if you said yes on LOCAL_PROXY_SERVER, you can point this to the local proxy
# and if you said no, you can point it directly to the external proxy (if any)
# note: only this host will benefit from this. to configure proxy use on other
# deployed VMs, configure adequate proxy parameters on fce config file (master.yaml)
# note2: local environment DOT NOT have a way to avoid proxy for specific networks,
# not even no_proxy will work (it's only for domains). Enable peer proxy if you need that.
ENV_PROXY=yes # Values: yes/no
ENV_PROXY_URI="http://192.168.210.1:3128"

# packages to install
INSTALL_PACKAGES=(
	bridge-utils
	virtinst
	libvirt-bin
	#libvirt-clients
	#libguestfs-tools
	qemu-kvm
	qemu-utils
	#bind9
	#bind9utils
	genisoimage
	iptables-persistent
	netfilter-persistent
	snap:juju
	snap:juju-wait
	snap:charm
	snap:lxd
	snap:kubectl
)

# list of VMs to create
# please account for the fact that the infra nodes will have VMs inside pods (i.e. juju) using
# nested virtualization, so at least 8GB for maas + juju only, more if you want to install LMA
# note: current limitations on infra nodes: their names must start with "infra*", and they can have
# only one disc and one nic, others will be ignored (this may be changed in a future version)
VM_LIST=(
	# vm              mem  disc1  disc2  disc3
	# name    vcpu     MB    GB     GB     GB   nics     ip address
	"infra1     2    8192    60      0      0     1   192.168.210.4"
	#"infra2     2    4096    60      0      0     1   192.168.210.5"
	#"infra3     2    4096    60      0      0     1   192.168.210.6"
	"node1      2    6144    60     50     50     5   -"
	"node2      2    6144    60     50     50     5   -"
	"node3      2    6144    60     50     50     5   -"
	"node4      2    6144    60     50     50     5   -"
	"node5      2    6144    60     50     50     5   -"
	"node6      2    6144    60     50     50     5   -"
	"node7      2    6144    60     50     50     5   -"
	"node8      2    6144    60     50     50     5   -"
	"node9      2    6144    60     50     50     5   -"
)

# list of layers to execute on install
# the order will be respected so you can arrange as needed
INSTALL_LAYERS=(
	proxyserver
	proxyclient
	packages
	#bcache
	keypair
	kvm
	vms
	network
	iptables
	bind
)

# list of layers to execute on install
# the order will be respected so you can arrange as needed
UNINSTALL_LAYERS=(
	bind
	iptables
	network
	vms
	kvm
	keypair
	#bcache
	#packages
	proxyclient
	proxyserver
)

