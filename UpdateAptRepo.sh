#!/bin/bash
set -x #echo on
echo "Update apt-repo..."
echo

repoName="$1"

if [ "$repoName" = "stable" ] || [ "$repoName" = "testing" ] ; then
   echo "Repo Name     : $repoName"
else
   echo "Repo Name must be specified: stable | testing"
   exit 1
fi

mkdir -p docs/$repoName

cp deb/$repoName/*.deb docs/$repoName/main/binary-amd64

cd docs/$repoName

mkdir -p main/binary-amd64

dpkg-scanpackages --multiversion --arch amd64 main/binary-amd64 > main/binary-amd64/Packages

cat main/binary-amd64/Packages | gzip -9 > main/binary-amd64/Packages.gz

apt-ftparchive release main/binary-amd64 > Release

cat Release | gpg --default-key design-to-production -abs > Release.gpg

cat Release | gpg --default-key design-to-production -abs --clearsign > InRelease

cd ../..