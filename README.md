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

Note: if you configure proxys, don't forget to exit shell and login again to load proxy environment variables in your session before trying to use fce tool.

Use case:

- Grab a server from FCE Lab, Huxton Lab, Icarus Lab or a server at home
- Install it by hand or using MAAS if available (this maas will not be used afterwards, new MAASes will be installed on your infra nodes, so this is just for baremetal initial setup speedup)
- Configure bcache (strongly advised) to cache your root filesystem
- Login to the server, download fce-lab-tool (you may have to configure proxy in git if no direct internet access)
- Edit config.inc.sh to adjust configurations and run fce-lab.sh
- Done, you are ready to install and use fce tool to deploy in the VMs.

(c) 2019 - Andre Ruiz

