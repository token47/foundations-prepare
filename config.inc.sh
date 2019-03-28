#!/bin/true # this script is not supposed to be run

# whether to deploy single node or three node high availability MaaS. 
HA=false  # single infra node

# whether to use proxy
PROXY=true
PROXY_HTTP="http://91.189.89.216:3128"
PROXY_HTTPS="http://91.189.89.216:3128"
PROXY_IGNORE="127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"

VM_DIR=~/virtual_machines
VM_LIST=(
	# name  vcpu  mem disc1 disc2 disc3 nics
	"infra1   2  4096   60     0     0   1"
	"infra2   2  4096   60     0     0   1"
	"infra3   2  4096   60     0     0   1"
	"juju     2  4096   20     0     0   1"
	"node1    2  6144   60   100   100   5"
	"node2    2  6144   60   100   100   5"
	"node3    2  6144   60   100   100   5"
	"node4    2  6144   60   100   100   5"
	"node5    2  6144   60   100   100   5"
	"node6    2  6144   60   100   100   5"
	"node7    2  6144   60   100   100   5"
	"node8    2  6144   60   100   100   5"
	"node9    2  6144   60   100   100   5"
)

# Network
INFRA1=192.168.210.4
INFRA2=192.168.210.5
INFRA3=192.168.210.6
GW=192.168.210.1
CIDR=192.168.210.0/24
CIDR_bits=24
BRIDGE=maasbr0

# location of log file
LOG=./output.txt

# other stuff
GREEN='\033[0;32m'
NC='\033[0m' # No Color

