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

mkdir -p docs/apt-repo/pool/main

cp deb/$repoName/*.deb docs/apt-repo/pool/main/$repoName

cd docs/apt-repo

mkdir -p dists/$repoName/main/binary-amd64

dpkg-scanpackages --multiversion --arch amd64 pool/main/$repoName > dists/$repoName/main/binary-amd64/Packages

cat dists/$repoName/binary-amd64/Packages | gzip -9 > dists/$repoName/main/binary-amd64/Packages.gz

apt-ftparchive release dists/$repoName/ > dists/$repoName/Release

cat dists/$repoName/Release | gpg --default-key design-to-production -abs > dists/$repoName/Release.gpg

cat dists/$repoName/Release | gpg --default-key design-to-production -abs --clearsign > dists/$repoName/InRelease

cd ../..