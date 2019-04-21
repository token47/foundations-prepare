#!/bin/bash

sudo brctl addbr maasbr0
sudo ip a add 192.168.210.1/24 dev maasbr0
sudo ip l set maasbr0 up

sudo iptables -t nat -A POSTROUTING -s 192.168.210.0/24 ! -d 192.168.210.0/24 -m comment --comment "network maasbr0" -j MASQUERADE
sudo iptables -t filter -A INPUT -i maasbr0 -p tcp -m tcp --dport 53 -m comment --comment "network maasbr0" -j ACCEPT
sudo iptables -t filter -A INPUT -i maasbr0 -p udp -m udp --dport 53 -m comment --comment "network maasbr0" -j ACCEPT
sudo iptables -t filter -A FORWARD -o maasbr0 -m comment --comment "network maasbr0" -j ACCEPT
sudo iptables -t filter -A FORWARD -i maasbr0 -m comment --comment "network maasbr0" -j ACCEPT

