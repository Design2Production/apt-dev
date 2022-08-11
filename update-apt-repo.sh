#!/bin/bash
#set -x #echo on
echo "Update apt-repo..."
echo

clientName="$1"
repoName="$2"

if [ "$clientName" = "shopper-media" ] || [ "$clientName" = "internal" ] ; then
   echo "Client         : $clientName"
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

cd docs/$clientName/$repoName

dpkg-scanpackages --multiversion --arch amd64 amd64 > Packages

cat Packages | gzip -9 > Packages.gz

apt-ftparchive release . > Release

cat Release | gpg --default-key design-to-production -abs > Release.gpg

cat Release | gpg --default-key design-to-production -abs --clearsign > InRelease

cd ../../..