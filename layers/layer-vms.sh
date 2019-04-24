#!/bin/true # this file is not supposed to be called directly

function create_infra_node() {

	local "$@"
	local VM_DIR="$HOME/virt/vms"

	hostlist="infra1"
	[ "$HA" = true ] && hostlist="infra1 infra2 infra3"

	oc3="$(printf '%02x\n' $(($RANDOM%256)) )"
	oc4="$(printf '%02x\n' $(($RANDOM%256)) )"
	oc5="$(printf '%02x\n' $(($RANDOM%256)) )"

	for host in $hostlist; do

		lib/kvm-install-vm \
			-b maasbr0 \
			-c $vcpu \
			-d $disc1 \
			-m $mem \
			-M "54:56:$oc3:$oc4:$oc5:01" \
			-t "ubuntu1804" \
			$host
	
	done
}

function create_normal_node() {

	local "$@"

	[ "$disc1" -gt 0 ] && qemu-img create -f qcow2 ${VM_DIR}/${name}-d1.qcow2 ${disc1}G
	[ "$disc2" -gt 0 ] && qemu-img create -f qcow2 ${VM_DIR}/${name}-d2.qcow2 ${disc2}G
	[ "$disc3" -gt 0 ] && qemu-img create -f qcow2 ${VM_DIR}/${name}-d3.qcow2 ${disc3}G

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
		     $( [ "$disc1" -gt 0 ] && echo "--disk path=${VM_DIR}/${name}-d1.qcow2,format=qcow2,bus=scsi,cache=writeback" ) \
		     $( [ "$disc2" -gt 0 ] && echo "--disk path=${VM_DIR}/${name}-d2.qcow2,format=qcow2,bus=scsi,cache=writeback" ) \
		     $( [ "$disc3" -gt 0 ] && echo "--disk path=${VM_DIR}/${name}-d3.qcow2,format=qcow2,bus=scsi,cache=writeback" ) \
		     $( [ "$nets" -ge 1 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc4:$oc3:$oc2:01,model=virtio" ) \
		     $( [ "$nets" -ge 2 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc4:$oc3:$oc2:02,model=virtio" ) \
		     $( [ "$nets" -ge 3 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc4:$oc3:$oc2:03,model=virtio" ) \
		     $( [ "$nets" -ge 4 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc4:$oc3:$oc2:04,model=virtio" ) \
		     $( [ "$nets" -ge 5 ] && echo "--network=bridge=${BRIDGE},mac=54:56:$oc4:$oc3:$oc2:05,model=virtio" )
		)

}

function layer_install() {

	local disc_opt=""

	for item in "${VM_LIST[@]}"; do

		local a=($item)
		name="${a[0]}" vcpu="${a[1]}" mem="${a[2]}"
		disc1="${a[3]}" disc2="${a[4]}" disc3="${a[5]}" nets="${a[6]}"

		if [[ "$name" ~= ^infra ]]; then
			create_infra_node
		else
			create_normal_node
		fi

	done

	virsh list --all
}

function layer_uninstall() {

}

