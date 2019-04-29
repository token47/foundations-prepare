# FCE Lab tool

- Sugested at least 8 procs and 64GB of ram, 1 TB disc
- Install Ubuntu Bionic 18.04 LTS, EFI + boot + giant root partition
- Strongly recommended to use bcache with SSD on the root partition
- Adjust configs on config.inc.sh
- Run ./fce-lab.sh -i to install (-u to uninstall)
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

Note: if you configure proxies, don't forget to exit shell and login again to load proxy environment variables in your session before trying to use fce tool.

# Use case:

- Grab a server from FCE Lab, Huxton Lab, Icarus Lab or a server at home
- Install it by hand or using MAAS if available (this maas will not be used afterwards, new MAASes will be installed on your infra nodes, so this is just for baremetal initial setup speedup)
- Configure bcache (strongly advised) to cache your root filesystem
- Login to the server, download fce-lab tool (you may have to configure proxy in git if no direct internet access)
- Edit config.inc.sh to adjust configurations and run fce-lab.sh
- Done, you are ready to install and use fce tool to deploy in the VMs.

The environment will have about 12 VMs representing 3 infra nodes and 9 generic nodes and configured to ease the quick testing of complete deploys on the lab.

# Random notes:

- You can route the ubuntu-net to the host easily adding a route for that network thru the neutron gateway's ip on the provider network. Ex. "ip route add 172.16.0.0/24 via 10.0.6.12".

- You may need to re-import the public key from maas@infra nodes to the host so it can remotely control power on libvirt vms. Sometimes a clean / build will erase the key. Use script "fix-kvm-power.sh" for that.

(c) 2019 - Andre Ruiz

