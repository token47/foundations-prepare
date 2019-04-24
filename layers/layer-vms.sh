#!/bin/true # this file is not supposed to be called directly

function create_infra_node() {

	[ "$HA" != "true" ] && [ "$name" == "infra2" -o "$name" == "infra3" ] && return

	oc3="$(printf '%02x\n' $(($RANDOM%256)) )"
	oc4="$(printf '%02x\n' $(($RANDOM%256)) )"
	oc5="$(printf '%02x\n' $(($RANDOM%256)) )"

	lib/kvm-install-vm create \
		-b maasbr0 \
		-c $vcpu \
		-d $disc1 \
		-m $mem \
		-M "54:56:$oc3:$oc4:$oc5:01" \
		-t "ubuntu1804" \
		$name
	
}

function create_normal_node() {

	local VM_DIR="$HOME/virt/vms"

	mkdir "$VM_DIR"/"$name"
	[ "$disc1" -gt 0 ] && qemu-img create -f qcow2 ${VM_DIR}/${name}/${name}-d1.qcow2 ${disc1}G
	[ "$disc2" -gt 0 ] && qemu-img create -f qcow2 ${VM_DIR}/${name}/${name}-d2.qcow2 ${disc2}G
	[ "$disc3" -gt 0 ] && qemu-img create -f qcow2 ${VM_DIR}/${name}/${name}-d3.qcow2 ${disc3}G

	oc3="$(printf '%02x\n' $(($RANDOM%256)) )"
	oc4="$(printf '%02x\n' $(($RANDOM%256)) )"
	oc5="$(printf '%02x\n' $(($RANDOM%256)) )"

	virsh define <(
		virt-install --print-xml \
		     --noautoconsole \
		     --virt-type kvm \
		     --boot network,hd,menu=on \
		     --name "${name}" \
		     --ram "${mem}" \
		     --vcpus "${vcpu}" \
		     --cpu host-passthrough,cache.mode=passthrough \
		     --graphics vnc --video=cirrus \
		     --os-type linux --os-variant ubuntu18.04 \
		     --controller scsi,model=virtio-scsi,index=0 \
		     $( [ "$disc1" -gt 0 ] && echo "--disk path=${VM_DIR}/${name}/${name}-d1.qcow2,format=qcow2,bus=scsi,cache=writeback" ) \
		     $( [ "$disc2" -gt 0 ] && echo "--disk path=${VM_DIR}/${name}/${name}-d2.qcow2,format=qcow2,bus=scsi,cache=writeback" ) \
		     $( [ "$disc3" -gt 0 ] && echo "--disk path=${VM_DIR}/${name}/${name}-d3.qcow2,format=qcow2,bus=scsi,cache=writeback" ) \
		     $( [ "$nets" -ge 1 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc3:$oc4:$oc5:01,model=virtio" ) \
		     $( [ "$nets" -ge 2 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc3:$oc4:$oc5:02,model=virtio" ) \
		     $( [ "$nets" -ge 3 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc3:$oc4:$oc5:03,model=virtio" ) \
		     $( [ "$nets" -ge 4 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc3:$oc4:$oc5:04,model=virtio" ) \
		     $( [ "$nets" -ge 5 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc3:$oc4:$oc5:05,model=virtio" )
		)

}

function layer_install() {

	for item in "${VM_LIST[@]}"; do

		local a=($item)
		name="${a[0]}" vcpu="${a[1]}" mem="${a[2]}"
		disc1="${a[3]}" disc2="${a[4]}" disc3="${a[5]}" nets="${a[6]}"

		if [[ "$name" =~ ^infra ]]; then
			create_infra_node
		else
			create_normal_node
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

		virsh destroy --domain "$name"
		virsh undefine --domain "$name"
		virsh pool-destroy "$name"

		rm -rf "${VM_DIR}/${name}"

	done

	virsh list --all

}

