#!/bin/bash
#set -x #echo on
echo "Install skittles ..."
echo

releaseName="$1"
test="$2"

if [ "$releaseName" = "stable" ] || [ "$releaseName" = "testing" ] || [ "$releaseName" = "prototype" ] ; then
   echo "Release Name          : $releaseName"
else
   echo "Release Name must be specified: stable | testing | prototype"
   exit 1
fi

wget -O install-dp-skittles-vending-edge-server.sh https://design2production.github.io/apt-dev/install-dp-skittles-vending-edge-server.sh  
wget -O install-dp-skittles.sh https://design2production.github.io/apt-dev/install-dp-skittles.sh  
wget -O install-dp-mdb-payment-processor.sh https://design2production.github.io/apt-dev/install-dp-mdb-payment-processor.sh

sh ./install-dp-skittles-vending-edge-server.sh $releaseName $test
sh ./install-dp-mdb-payment-processor.sh $releaseName
sh ./install-dp-skittles.sh $releaseName

echo "... skittles installation complete."