#!/bin/true # this script is not supposed to be run

# (c) Andre Ruiz 2019

# whether to deploy single node or three node high availability MaaS. 
HA=false  # single infra node

# Network
INFRA1=192.168.210.4
INFRA2=192.168.210.5
INFRA3=192.168.210.6
CIDR=192.168.210.0/24
CIDR_bits=24
IPADDR=192.168.210.1
BRIDGE=maasbr0

# whether to set up a local proxy (on this host)
# my sugestion is to answer yes here, and consider this the main proxy of the environment
# then set this host as the maas proxy in master.yaml (and disable peer proxy)
# also, set all proxies for apt, juju and others in master.yaml to this one too
LOCAL_PROXY=yes

# whether to use external proxy as a peer
# the local proxy will forward to this proxy
# networks on the ignore list will be accessed directly (not forwarded)
PEER_PROXY=yes
PEER_PROXY_ADDR="http://91.189.89.216:3128"
PEER_PROXY_IGNORE="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

# whether to put proxy variables on the environment of this host (/etc/environment)
# this will set http_proxy and https_proxy env vars on this host shells, also
# configure snap, apt and other apps to use the proxy
# note: only this host will benefit from this. to configure proxy use on other deployed
# VMs, configure adequate proxy parameters on fce config file (master.yaml)
ENV_PROXY=yes
ENV_PROXY_HTTP="http://91.189.89.216:3128"
ENV_PROXY_HTTPS="http://91.189.89.216:3128"

# packages to install
INSTALL_PACKAGES=(
	bridge-utils
	libvirt-bin
	qemu-utils
	virtinst
	qemu-kvm
	bind9
	bind9utils
	openstack
	snap:juju
	snap:juju-wait
	snap:charm
	snap:lxd
	snap:kubectl
)

# list of VMs to create
# please account for the fact that the infra nodes will have VMs inside pods (i.e. juju)
# so at least 8GB for maas + juju only, more if you want to install LMA
# infra2 and infra3 will be ignored if you use HA=false, no need to remove them from the list
VM_DIR=~/virtual_machines
VM_LIST=(
	# vm              mem  disc1  disc2  disc3
	# name    vcpu     MB    GB     GB     GB   nics
	"infra1     2    8192    60      0      0     1"
	"infra2     2    4096    60      0      0     1"
	"infra3     2    4096    60      0      0     1"
	"node1      2    6144    60     50     50     5"
	"node2      2    6144    60     50     50     5"
	"node3      2    6144    60     50     50     5"
	"node4      2    6144    60     50     50     5"
	"node5      2    6144    60     50     50     5"
	"node6      2    6144    60     50     50     5"
	"node7      2    6144    60     50     50     5"
	"node8      2    6144    60     50     50     5"
	"node9      2    6144    60     50     50     5"
)

# list of layers to execute on install
# the order will be respected so you can arrange as needed
INSTALL_LAYERS=(
	proxy
	packages
	kvm
	vms
	network
	iptables
	bind
	keypair
	ssh
)

# list of layers to execute on install
# the order will be respected so you can arrange as needed
UNINSTALL_LAYERS=(
	ssh
	keypair
	bind
	iptables
	network
	kvm
	vms
	#packages
	proxy
)
