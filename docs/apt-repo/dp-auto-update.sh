#!/bin/bash
apt-get update
apt-get upgrade -y -o Dpkg::Options::="--force-confold"
apt-get autoclean