#!/bin/bash

key="$(ssh 192.168.210.4 "sudo -u maas ssh-keygen -y -f /var/lib/maas/.ssh/id_rsa")"

if [ $? -eq 0 ]; then
	echo "$key maas@infra1" >> ~/.ssh/authorized_keys
	echo "Done"
else
	echo "No key found (yet)"
fi

