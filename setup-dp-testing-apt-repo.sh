#!/bin/bash
set -x #echo on

wget -P /tmp -nc https://design2production.github.io/apt/apt-repo/dp-key.gpg
install -o root -g root -m 644 /tmp/dp-key.gpg /etc/apt/trusted.gpg.d/
wget -P /etc/apt/sources.list.d -nc https://design2production.github.io/apt/apt-repo/dp-testing.list
apt-get update