# FCE Lab tool

- Sugested at least 8 procs and 64GB of ram, 1 TB disc
- Install Ubuntu Bionic 18.04 LTS, EFI + boot + giant root partition
- Strongly recommended to use bcache with SSD on the root partition
- Adjust configs on config.inc.sh
- Run ./fcelab.sh -i to install (-u to uninstall)
- Download fce-templates and cpe-foundation and enjoy

This script will:

- configure proxy (client host and squid server)
- install package dependencies
- set up kvm for nested virtualization
- create VMs for the lab deployment
- configure network, bridges, ips and routes
- iptables rules and NAT for the lab
- DNS recursion
- ssh and keypairs
- tune bcache

Most of it should be configurable. It will also uninstall everything if you want to start over.

(c) 2019 - Andre Ruiz

