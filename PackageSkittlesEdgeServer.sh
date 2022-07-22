#!/bin/bash
set -x #echo on
echo "Package SkittlesEdgeServer..."
echo
packageName="$1"
version=$2
release=$3
architecture="amd64"
_="_"
sourceFolder="$4"

if [ "$packageName" = "" ] ; then
   echo "Package Name must be specified"
   exit 1
else
   echo "Package Name     : $packageName"
fi

if [ "$version" = "" ] ; then
   echo "Version must be specified as x.y.z"
   exit 1
else
   echo "Version          : $version"
fi

if [ "$release" = "" ] ; then
   echo "Release must be specified"
   exit 1
else
   echo "Release          : $release"
fi

if [ "$sourceFolder" = "" ] ; then
   echo "Source Folder be specified"
   exit 1
else
   echo "Source Folder    : $sourceFolder"
fi

fullPackageName="$packageName$_$version$_$release$_$architecture"

echo "Full Package Name : $fullPackageName"

rm -r $fullPackageName
mkdir -p $fullPackageName/usr/bin
cp -r $sourceFolder/SkittlesEdgeServer $fullPackageName/usr/bin
chmod 777 $fullPackageName/usr/bin/SkittlesEdgeServer/SkittlesVending.EdgeServer

mkdir -p $fullPackageName/DEBIAN

echo "Package: $packageName
Version: $version
Maintainer: Design to Production <support@d-p.com.au>
Depends:
Architecture: amd64
Homepage: http://d-p.com.au
Description: Skittles Edge Server Application" \
> $fullPackageName/DEBIAN/control

dpkg-deb --build $fullPackageName
