#!/bin/bash
set -x #echo on
echo "Create Apt Repo..."
echo

mkdir -p apt-repo/pool/main

cp *.deb apt-repo/pool/main/.

mkdir -p apt-repo/dists/stable/main/binary-amd64

dpkg-scanpackages --arch amd64 apt-repo/pool/ > apt-repo/dists/stable/main/binary-amd64/Packages

cat apt-repo/dists/stable/main/binary-amd64/Packages | gzip -9 > apt-repo/dists/stable/main/binary-amd64/Packages.gz

apt-ftparchive release apt-repo/dists/stable/ > apt-repo/dists/stable/Release
