#!/bin/bash
set -x #echo on
echo "Update apt-repo..."
echo

#mkdir -p apt-repo/pool/main

cp deb/*.deb docs/apt-repo/pool/main/.

#mkdir -p apt-repo/dists/stable/main/binary-amd64

cd docs/apt-repo

dpkg-scanpackages --multiversion --arch amd64 pool/ > dists/stable/main/binary-amd64/Packages

cat dists/stable/main/binary-amd64/Packages | gzip -9 > dists/stable/main/binary-amd64/Packages.gz

apt-ftparchive release dists/stable/ > dists/stable/Release

cat dists/stable/Release | gpg --default-key design-to-production -abs > dists/stable/Release.gpg

cat dists/stable/Release | gpg --default-key design-to-production -abs --clearsign > dists/stable/InRelease

cd ../..
