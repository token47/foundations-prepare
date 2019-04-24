#!/bin/true # this script is not supposed to be run

# (c) Andre Ruiz 2019

# whether to deploy single node or three node high availability MaaS. 
HA=false  # single infra node or three nodes cluster (true/false)

# Ip address of the bridge on the host. The first ip is mandatory the others will be aliases
# on the same bridge to facilitate accessing openstack networks from the host
BRIDGE=maasbr0
IPADDR=(
	192.168.210.1/24
	10.0.1.1/24
	10.0.2.1/24
	10.0.3.1/24
	10.0.6.0/24
)

# The ip addresses of the infra nodes (2 and 3 will be ignored if not using HA)
INFRA1=192.168.210.4
INFRA2=192.168.210.5
INFRA3=192.168.210.6

# whether to set up a local squid proxy service on this host
# my sugestion is to answer yes here, and consider this the main proxy of the environment
# then use this host as the maas proxy in master.yaml (and disable peer proxy)
# also, set all proxies for apt, juju and others in master.yaml to this one too
# this also helps keeping maas disk small (avoid proxy cache inside maas)
LOCAL_PROXY=yes

# whether to use external proxy as a peer (forwarder) for the local proxy
# networks on the ignore list will be accessed directly (not forwarded)
# this is very useful because you cannot easily control which networks
# you do not want to send to the proxy if you use the external proxy directly
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
	wget
	bridge-utils
	libvirt-bin
	libvirt-client
	qemu-utils
	virtinst
	qemu-kvm
	qemu-img
	bind9
	bind9utils
	squid
	genisoimage
	virt-install
	libguestfs-tools-c
	snap:juju
	snap:juju-wait
	snap:charm
	snap:lxd
	snap:kubectl
)

# list of VMs to create
# please account for the fact that the infra nodes will have VMs inside pods (i.e. juju) using
# nested virtualization, so at least 8GB for maas + juju only, more if you want to install LMA
# infra2 and infra3 will be ignored if you use HA=false, no need to remove them from the list
# note: current limitations on infra nodes: you cannot change their names, and they can have
# only one disc and one nic, others will be ignored (this may be changed in a future version)
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
	keypair
	vms
	network
	iptables
	bind
	ssh
)

# list of layers to execute on install
# the order will be respected so you can arrange as needed
UNINSTALL_LAYERS=(
	ssh
	bind
	iptables
	network
	vms
	#keypair
	kvm
	#packages
	proxy
)
