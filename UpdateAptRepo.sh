#!/bin/bash
set -x #echo on
echo "Update apt-repo..."
echo

#mkdir -p apt-repo/pool/main

cp deb/*.deb docs/apt-repo/pool/main/.

#mkdir -p apt-repo/dists/stable/main/binary-amd64

dpkg-scanpackages --multiversion --arch amd64 docs/apt-repo/pool/ > docs/apt-repo/dists/stable/main/binary-amd64/Packages

cat docs/apt-repo/dists/stable/main/binary-amd64/Packages | gzip -9 > docs/apt-repo/dists/stable/main/binary-amd64/Packages.gz

apt-ftparchive release docs/apt-repo/dists/stable/ > docs/apt-repo/dists/stable/Release
