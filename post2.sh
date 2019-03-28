#!/bin/bash

echo "$(ssh 192.168.210.4 "sudo -u maas ssh-keygen -y -f /var/lib/maas/.ssh/id_rsa") maas@infra1" >> .ssh/authorized_keys

