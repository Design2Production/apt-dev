#!/bin/bash
#set -x #echo on
echo "Update apt repo..."
echo

repoName="$1"
releaseName="$2"

if [ "$repoName" = "dpems" ] || [ "$repoName" = "skittles" ] ; then
   echo "Repo        : $repoName"
else
   echo "Repo must be specified: dpems | skittles"
   exit 1
fi

if [ "$releaseName" = "stable" ] || [ "$releaseName" = "testing" ] ; then
   echo "Release Name: $releaseName"
else
   echo "Release Name must be specified: stable | testing"
   exit 1
fi

cd docs/$repoName/$releaseName

dpkg-scanpackages --multiversion --arch amd64 amd64 > Packages

cat Packages | gzip -9 > Packages.gz

apt-ftparchive release . > Release

cat Release | gpg --default-key design-to-production -abs > Release.gpg

cat Release | gpg --default-key design-to-production -abs --clearsign > InRelease

cd ../../..