#!/bin/true # this file is not supposed to be called directly

function define_instance() {

	local "$@"

	local oc3="$(printf '%02x\n' $(($RANDOM%256)) )"
	local oc4="$(printf '%02x\n' $(($RANDOM%256)) )"
	local oc5="$(printf '%02x\n' $(($RANDOM%256)) )"

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
		        echo -n "--disk format=qcow2,bus=scsi,cache=writeback,";
			echo -n "path=${vm_dir}/${name}-d1.qcow2"; } ) \
		     $( [ "$disc2" -gt 0 ] && {
		        echo -n "--disk format=qcow2,bus=scsi,cache=writeback,";
			echo -n "path=${vm_dir}/${name}-d2.qcow2"; } ) \
		     $( [ "$disc3" -gt 0 ] && {
		        echo -n "--disk format=qcow2,bus=scsi,cache=writeback,";
			echo -n "path=${vm_dir}/${name}-d3.qcow2"; } ) \
		     $( [ "$cloudinit" == "yes" ] && {
			echo -n "--disk device=cdrom,";
		        echo -n "path=${vm_dir}/${name}-cloudinit.iso"; } ) \
		     $( [ "$nets" -ge 1 ] && { echo -n "--network=bridge=${BRIDGE},";
			echo -n "mac=54:56:$oc3:$oc4:$oc5:01,model=virtio"; } ) \
		     $( [ "$nets" -ge 2 ] && { echo -n "--network=bridge=${BRIDGE},";
			echo -n "mac=54:56:$oc3:$oc4:$oc5:02,model=virtio"; } ) \
		     $( [ "$nets" -ge 3 ] && { echo -n "--network=bridge=${BRIDGE},";
			echo -n "mac=54:56:$oc3:$oc4:$oc5:03,model=virtio"; } ) \
		     $( [ "$nets" -ge 4 ] && { echo -n "--network=bridge=${BRIDGE},";
			echo -n "mac=54:56:$oc3:$oc4:$oc5:04,model=virtio"; } ) \
		     $( [ "$nets" -ge 5 ] && { echo -n "--network=bridge=${BRIDGE},";
			echo -n "mac=54:56:$oc3:$oc4:$oc5:05,model=virtio"; } )

		)

}


function create_node_image() {

	local pub_key ci_userdata ci_networkconfig

	# presumably the image is a qcow2 format even though the image has .img extension (ubuntu is)
	cp ~/images/"$IMAGE_NAME" "${vm_dir}/${name}-d1.qcow2"
	qemu-img resize "${vm_dir}/${name}-d1.qcow2" "${disc1}"G
	[ "$disc2" -gt 0 ] && qemu-img create -f qcow2 "${vm_dir}/${name}-d2.qcow2" "${disc2}G"
	[ "$disc3" -gt 0 ] && qemu-img create -f qcow2 "${vm_dir}/${name}-d3.qcow2" "${disc3}G"

	pub_key="$(cat ~/.ssh/id_rsa.pub)"

	ci_userdata=$(mktemp /tmp/fce-lab.XXXXXXX)
	ci_networkconfig=$(mktemp /tmp/fce-lab.XXXXXXX)

	cat <<-EOF > $ci_userdata
	#cloud-config
	hostname: ${name}
	users:
	  - default
	  - name: ubuntu
	    ssh_authorized_keys:
	      - ${pub_key}
	package_update: true
	package_upgrade: true
	packages:
	  - bridge-utils
	  - qemu-kvm
	  - libvirt-bin
	runcmd:
	  - systemctl disable cloud-init.service
	  - systemctl disable cloud-init-local.service
	  - systemctl disable cloud-final.service
	  - systemctl disable cloud-config.service
	power_state:
	  mode: reboot
	EOF

	[ "$ENV_PROXY" == "yes" ] && cat <<-EOF >> $ci_userdata
	#apt:
	#  proxy: ${ENV_PROXY_URI}
	#  http_proxy: ${ENV_PROXY_URI}
	#  https_proxy: ${ENV_PROXY_URI}
	#runcmd:
	#  - echo "http_proxy='${ENV_PROXY_URI}'  # fce-lab tool" >> /etc/environment
	#  - echo "https_proxy='${ENV_PROXY_URI}'  # fce-lab tool" >> /etc/environment
	#  - echo "no_proxy='localhost,127.0.0.1'  # fce-lab tool" >> /etc/environment
	#  - systemctl restart snapd
	EOF

	cat <<-EOF > $ci_networkconfig
	version: 2
	ethernets:
	  ens3:
	    dhcp4: false
	bridges:   
	  broam:   
	    dhcp4: false   
	    interfaces: [ ens3 ]
	    addresses: [ ${ip} ]
	    gateway4: ${IPADDR[0]/\/*/}
	    nameservers:
	      search: [ 'maas' ]
	      addresses: [ ${IPADDR[0]/\/*/} ]
	    parameters:
	      stp: false   
	      forward-delay: 0
	EOF

	cloud-localds -d raw -f iso -m local \
		-N "$ci_networkconfig" \
		"${vm_dir}/${name}-cloudinit.iso" \
		"$ci_userdata"

	define_instance boot="hd,menu=off" cloudinit=yes
	
	virsh autostart "${name}"
	virsh start "${name}"

	rm -f $ci_userdata $ci_networkconfig

}


function create_node_network() {

	[ "$disc1" -gt 0 ] && qemu-img create -f qcow2 "${vm_dir}/${name}-d1.qcow2" "${disc1}G"
	[ "$disc2" -gt 0 ] && qemu-img create -f qcow2 "${vm_dir}/${name}-d2.qcow2" "${disc2}G"
	[ "$disc3" -gt 0 ] && qemu-img create -f qcow2 "${vm_dir}/${name}-d3.qcow2" "${disc3}G"

	define_instance boot="network,hd,menu=on" cloudinit=no

}


function destroy_node() {

		virsh destroy --domain "$name" || :
		virsh undefine --domain "$name" || :

}


function layer_install() {

	local vm_dir="$HOME/vms"

	[ -d "$vm_dir" ] || mkdir "$vm_dir"

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

	local vm_dir="$HOME/vms"

	virsh list --all

	for item in "${VM_LIST[@]}"; do

		local a=($item)
		type="${a[0]}"; name="${a[1]}"; vcpu="${a[2]}"; mem="${a[3]}"; disc1="${a[4]}";
		disc2="${a[5]}"; disc3="${a[6]}"; nets="${a[7]}"; ip="${a[8]}";

		destroy_node

	done

	sudo rm -rf "${vm_dir}"

	virsh list --all

}

