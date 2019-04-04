#!/bin/bash

git config --global http.proxy http://91.189.89.216:3128
git config --global https.proxy http://91.189.89.216:3128
git config --global user.name Andre Ruiz
git config --global user.email andre.ruiz@canonical.com
git config --global core.editor vim
git config --global url.git+ssh://andre-ruiz@git.launchpad.net/.insteadof lp:

mkdir ~/.ssh 2>/dev/null
cat << EOF >> ~/.ssh/config
Host *.lxd
        CheckHostIP no
        StrictHostKeyChecking no
        ProxyCommand nc \$(lxc list -c s4 \$(echo %h | sed "s/\\.lxd//g") | grep RUNNING | cut -d' ' -f4) %p
        ForwardAgent yes
        User ubuntu
        ForwardX11 yes

Host git.launchpad.net bazaar.launchpad.net
        UserKnownHostsFile /dev/null
        StrictHostKeyChecking no
        CheckHostIP no
        User andre-ruiz
EOF

for i in 10.0.1.1/24 10.0.2.1/24 10.0.3.1/24 10.0.4.1/24; do
	sudo ip addr add $i dev maasbr0
done

exit 0

# just for reference

export https_proxy=http://91.189.89.216:3128
export http_proxy=http://91.189.89.216:3128
export no_proxy=127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16

