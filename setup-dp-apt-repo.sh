#!/bin/bash
#set -x #echo on

clientName="$1"
repoName="$2"

if [ "$clientName" = "shopper-media" ] || [ "$clientName" = "internal" ] ; then
   echo "Client           : $clientName"
else
   echo "Client must be specified: shopper-media | internal"
   exit 1
fi

if [ "$repoName" = "stable" ] || [ "$repoName" = "testing" ] ; then
   echo "Repo Name     : $repoName"
else
   echo "Repo Name must be specified: stable | testing"
   exit 1
fi

url="https://design2production.github.io/apt/dp-apt-$clientName-$repoName.list"

wget -P /etc/apt/sources.list.d -nc $url
apt-get update