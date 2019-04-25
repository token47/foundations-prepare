#!/bin/true # this file is not supposed to be called directly

function layer_install() {

	if [[ $(lscpu | grep Intel) ]]; then
		sudo modprobe -r kvm_intel
		cat <<-EOF | sudo tee /etc/modprobe.d/kvm.conf >/dev/null
		options kvm_intel nested=1
		options kvm_intel enable_shadow_vmcs=1
		options kvm_intel enable_apicv=1
		options kvm_intel ept=1	
		EOF
		sudo modprobe -a kvm_intel
	else
		sudo modprobe -r kvm_amd
		cat <<-EOF | sudo tee /etc/modprobe.d/kvm.conf >/dev/null
		options kvm_amd nested=1
		EOF
		sudo modprobe -a kvm_amd
	fi

	virt-host-validate
	
}

function layer_uninstall() {

	if [[ $(lscpu | grep Intel) ]]; then
		sudo modprobe -r kvm_intel
		sudo rm -f /etc/modprobe.d/kvm.conf
		sudo modprobe -a kvm_intel
	else
		sudo modprobe -r kvm_amd
		sudo rm -f /etc/modprobe.d/kvm.conf
		sudo modprobe -a kvm_amd
	fi

}

