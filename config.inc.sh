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
	cloud-image-utils
	virtinst
	libvirt-bin
	qemu-kvm
	qemu-utils
	#libvirt-clients
	#libguestfs-tools
	iptables-persistent
	netfilter-persistent
	#bind9
	#bind9utils
	snap:juju
	snap:juju-wait
	snap:charm
	snap:lxd
	snap:kubectl
)

# list of VMs to create
# please account for the fact that the infra nodes will have VMs inside pods (i.e. juju) using
# nested virtualization, so at least 8GB for maas + juju only, more if you want to install LMA
# type=infra means linux will be installed, boot from hd, and the vm will power on automatically
# type=node means no linux installation, boot from network (so the IP address is ignored)
# use disc = 0 to disable. nics is maximum 5.
VM_LIST=(
#	   vm     vm              mem  disc1  disc2  disc3
#	  type    name    vcpu     MB    GB     GB     GB   nics    oam ip address
	"infra   infra1     2    8192    60      0      0     1     192.168.210.4/24"
	#"infra   infra2     2    4096    60      0      0     1     192.168.210.5/24"
	#"infra   infra3     2    4096    60      0      0     1     192.168.210.6/24"
	"node    node1      2    6144    60     50     50     5     -"
	"node    node2      2    6144    60     50     50     5     -"
	"node    node3      2    6144    60     50     50     5     -"
	"node    node4      2    6144    60     50     50     5     -"
	"node    node5      2    6144    60     50     50     5     -"
	"node    node6      2    6144    60     50     50     5     -"
	"node    node7      2    6144    60     50     50     5     -"
	"node    node8      2    6144    60     50     50     5     -"
	"node    node9      2    6144    60     50     50     5     -"
)

# image to download for deploying infra nodes (QEMU QCOW v2 images only)
IMAGE_LOCATION="https://cloud-images.ubuntu.com/releases/18.04/release"
IMAGE_NAME="ubuntu-18.04-server-cloudimg-amd64.img"
IMAGE_KVM_OS_VARIANT="ubuntu18.04"

# list of layers to execute on install
# the order will be respected so you can arrange as needed
# comment out those you don't want to run
INSTALL_LAYERS=(
	#network
	#proxyserver
	#proxyclient
	#packages
	##bcache
	#keypair
	#kvm
	#dlimg
	vms
	#iptables
	##bind
)

# list of layers to execute on uninstall
# the order will be respected so you can arrange as needed
# comment out those you don't want to run
UNINSTALL_LAYERS=(
	##bind
	#iptables
	vms
	##dlimg
	#kvm
	#keypair
	##bcache
	##packages
	#proxyclient
	#proxyserver
	#network
)

