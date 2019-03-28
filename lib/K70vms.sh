#!/bin/bash

source $(dirname $0)/../config.inc.sh
source $(dirname $0)/utils.inc.sh

for item in "${VM_LIST[@]}"; do
	a=($item)
	name="${a[0]}"

	virsh destroy --domain "${name}" 2>/dev/null
	virsh undefine --domain "${name}"

	rm -f "${VM_DIR}/${name}-d"*".qcow2"
done

rmdir "$VM_DIR"



