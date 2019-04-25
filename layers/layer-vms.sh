#!/bin/true # this file is not supposed to be called directly

#function create_node_xxx() {
#
#	local oc3 oc4 oc5
#
#	oc3="$(printf '%02x\n' $(($RANDOM%256)) )"
#	oc4="$(printf '%02x\n' $(($RANDOM%256)) )"
#	oc5="$(printf '%02x\n' $(($RANDOM%256)) )"
#
#	set -x
#
#	sudo -i -l ubuntu -- lib/kvm-install-vm create -a \
#		-b $BRIDGE \
#		-c $vcpu \
#		-d $disc1 \
#		-m $mem \
#		-M "54:56:$oc3:$oc4:$oc5:01" \
#		-t "ubuntu1804" \
#		$name
#	set +x
#
#}

function define_instance() {

	local "$@"
	local oc3 oc4 oc5

	oc3="$(printf '%02x\n' $(($RANDOM%256)) )"
	oc4="$(printf '%02x\n' $(($RANDOM%256)) )"
	oc5="$(printf '%02x\n' $(($RANDOM%256)) )"

	virsh define <(
		virt-install --print-xml \
		     --noautoconsole \
		     --virt-type kvm \
		     --boot "${boot}" \
		     --name "${name}" \
		     --ram "${mem}" \
		     --vcpus "${vcpu}" \
		     --cpu host-passthrough,cache.mode=passthrough \
		     --graphics vnc --video=cirrus \
		     --os-type linux --os-variant "${IMAGE_KVM_OS_VARIANT}" \
		     --controller scsi,model=virtio-scsi,index=0 \
		     $( [ "$disc1" -gt 0 ] && {
		        echo -n "--disk format=qcow2,bus=scsi,cache=writeback,"
			echo -n "path=${VM_DIR}/${name}/${name}-d1.qcow2" } ) \
		     $( [ "$disc2" -gt 0 ] && {
		        echo -n "--disk format=qcow2,bus=scsi,cache=writeback,"
			echo -n "path=${VM_DIR}/${name}/${name}-d2.qcow2" } ) \
		     $( [ "$disc3" -gt 0 ] && {
		        echo -n "--disk format=qcow2,bus=scsi,cache=writeback,"
			echo -n "path=${VM_DIR}/${name}/${name}-d3.qcow2" } ) \
		     $( [ "$cloudinit" == "yes" ] && {
			echo -n "--disk device=cdrom,"
		        echo -n "path="${VM_DIR}"/"${name}"/"${name}"-cloudinit.iso" } ) \
		     $( [ "$nets" -ge 1 ] && { echo -n "--network=bridge=${BRIDGE},"
			echo -n "mac=54:56:$oc3:$oc4:$oc5:01,model=virtio" } ) \
		     $( [ "$nets" -ge 2 ] && { echo -n "--network=bridge=${BRIDGE},"
			echo -n "mac=54:56:$oc3:$oc4:$oc5:02,model=virtio" } ) \
		     $( [ "$nets" -ge 3 ] && { echo -n "--network=bridge=${BRIDGE},"
			echo -n "mac=54:56:$oc3:$oc4:$oc5:03,model=virtio" } ) \
		     $( [ "$nets" -ge 4 ] && { echo -n "--network=bridge=${BRIDGE},"
			echo -n "mac=54:56:$oc3:$oc4:$oc5:04,model=virtio" } ) \
		     $( [ "$nets" -ge 5 ] && { echo -n "--network=bridge=${BRIDGE},"
			echo -n "mac=54:56:$oc3:$oc4:$oc5:05,model=virtio" } ) \

		)

}


function create_node_image() {

	local pub_key cloudinitdir

	# presumably the image is a qcow2 format even though the image has .img extension (ubuntu is)
	cp ~/images/"$IMAGE_NAME" "${VM_DIR}"/"${name}"/"${name}"-d1.qcow2
	qemu-img resize "${VM_DIR}"/"${name}"/"${name}"-d1.qcow2 "${disc1}"G
	[ "$disc2" -gt 0 ] && qemu-img create -f qcow2 "${VM_DIR}"/"${name}"/"${name}"-d2.qcow2 "${disc2}"G
	[ "$disc3" -gt 0 ] && qemu-img create -f qcow2 "${VM_DIR}"/"${name}"/"${name}"-d3.qcow2 "${disc3}"G

	define_instance boot="hd,menu=off"

	pub_key="$(cat ~/.ssh/id_rsa.pub)"

	cloudinitdir=$(mktemp -d /tmp/fce-lab.XXXXXXX)

	cat <<-EOF | sudo tee $cloudinitdir/user-data >/dev/null
	#cloud-config
	preserve_hostname: false
	hostname: ${name}
	fqdn: ${name}.maas
	package_update: true
	package_upgrade: true
	packages:
	  - bridge-utils
	  - qemu-kvm
	  - libvirt-bin
	ssh_authorized_keys:
	  - ${pub_key}
	users:
	  - name: ubuntu
	    sudo: ALL=(ALL) NOPASSWD:ALL
	    home: /home/ubuntu
	    shell: /bin/bash
	    groups: [adm, audio, cdrom, dialout, floppy, video, plugdev, dip, netdev, libvirtd]
	    lock_passwd: True
	    gecos: Ubuntu
	    ssh_authorized_keys:
	      - ${pub_key}
	system_info:
	  network:
	    renderers: ['netplan']
	network:
	  version: 2
	  renderer: networkd
	  ethernets:
	    ens3:
	      dhcp4: false
	bridges:   
	  broam:   
	    interfaces: ens3
	    dhcp4: false   
	    dhcp6: false   
	    addresses: [ ${ip} ]
	    gateway4: ${IPADDR[0]}
	    nameservers:
	      search: [maas]
	      addresses: [${IPADDR[0]}]
	    parameters:   
	      stp: false   
	      forward-delay: 0
	EOF

	if [ "$ENV_PROXY" == "yes" ]; then

		cat <<-EOF | sudo tee -a $cloudinitdir/user-data >/dev/null
		apt:
		  proxy: ${ENV_PROXY_URI}
		  http_proxy: ${ENV_PROXY_URI}
		  https_proxy: ${ENV_PROXY_URI}
		runcmd:
		  - echo "http_proxy=\"${ENV_PROXY_URI}\"  # fce-lab tool" >> /etc/environment
		  - echo "https_proxy=\"${ENV_PROXY_URI}\"  # fce-lab tool" >> /etc/environment
		  - echo "no_proxy=\"localhost,127.0.0.1\"  # fce-lab tool" >> /etc/environment
		  - systemctl restart snapd
		  - systemctl disable cloud-init.service
		EOF
	
	fi

	cloud-localds -d raw -f iso \
		"${VM_DIR}"/"${name}"/"${name}"-cloudinit.iso $cloudinitdir/user-data

	define_instance boot="hd,menu=off" cloudinit=yes

	rm -rf $cloudinitdir

}


function create_node_network() {

	[ "$disc1" -gt 0 ] && qemu-img create -f qcow2 "${VM_DIR}"/"${name}"/"${name}"-d1.qcow2 "${disc1}"G
	[ "$disc2" -gt 0 ] && qemu-img create -f qcow2 "${VM_DIR}"/"${name}"/"${name}"-d2.qcow2 "${disc2}"G
	[ "$disc3" -gt 0 ] && qemu-img create -f qcow2 "${VM_DIR}"/"${name}"/"${name}"-d3.qcow2 "${disc3}"G

	define_instance boot="network,hd,menu=on" cloudinit=no

}

function layer_install() {

	local VM_DIR="$HOME/vms"

	[ -d "$VM_DIR"/"$name" ] || mkdir -p "$VM_DIR"/"$name"

	for item in "${VM_LIST[@]}"; do

		local a=($item)
		type="${a[0]}"; name="${a[1]}"; vcpu="${a[2]}"; mem="${a[3]}"; disc1="${a[4]}";
		disc2="${a[5]}"; disc3="${a[6]}"; nets="${a[7]}"; ip="${a[8]}";

		if [ "$type" == "infra" ]; then
			create_node_image
		else
			create_node_network
		fi

	done

	virsh list --all
}

function layer_uninstall() {

	local VM_DIR="$HOME/virt/vms"

	virsh list --all

	for item in "${VM_LIST[@]}"; do

		local a=($item)
		name="${a[0]}" vcpu="${a[1]}" mem="${a[2]}"
		disc1="${a[3]}" disc2="${a[4]}" disc3="${a[5]}" nets="${a[6]}"

		virsh destroy --domain "$name" || :
		virsh undefine --domain "$name" || :
		virsh pool-destroy "$name" || :

		rm -rf "${VM_DIR}/${name}"

	done

	virsh list --all

}

