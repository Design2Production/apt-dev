#!/bin/bash
set -x #echo on
echo "Update apt-repo..."
echo

#mkdir -p apt-repo/pool/main

cp deb/*.deb docs/apt-repo/pool/main/.

#mkdir -p apt-repo/dists/stable/main/binary-amd64

cd docs

dpkg-scanpackages --multiversion --arch amd64 apt-repo/pool/ > apt-repo/dists/stable/main/binary-amd64/Packages

cat apt-repo/dists/stable/main/binary-amd64/Packages | gzip -9 > apt-repo/dists/stable/main/binary-amd64/Packages.gz

apt-ftparchive release apt-repo/dists/stable/ > apt-repo/dists/stable/Release

cat apt-repo/dists/stable/Release | gpg --default-key design-to-production -abs --clearsign > apt-repo/dists/stable/InRelease

cd ..
