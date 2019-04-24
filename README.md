# FCE Lab tool

- Sugested at least 8 procs and 64GB of ram, 1 TB disc
- Install Ubuntu Bionic 18.04 LTS, EFI + boot + giant root partition
- Strongly recommended to use bcache with SSD on the root partition
- Adjust configs on config.inc.sh
- Run ./fcelab.sh -i to install (-u to uninstall)
- Download fce-templates and cpe-foundation and enjoy

This script will configure proxy, install packages, set up kvm, create VMs, configure network, iptables rules, DNS, ssh and keypairs, among other stuff.

