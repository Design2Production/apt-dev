#!/bin/bash
#set -x #echo on
wget -P /tmp -nc https://design2production.github.io/apt/dp-key.gpg
install -o root -g root -m 644 /tmp/dp-key.gpg /etc/apt/trusted.gpg.d/
wget -P /etc/apt/sources.list.d -nc https://design2production.github.io/apt/dp-apt-internal-stable.list
apt-get update