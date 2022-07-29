#!/bin/bash shopt -s extglob
set -x #echo on
echo "Package SkittlesEdgeServer..."
echo
packageName="$1"
version=$2
release=$3
architecture="amd64"
us="_"
sourceFolder="$4"
destinationFolder="CodeForPackaging"
repoName="$5"

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

if [ "$repoName" = "stable" ] || [ "$repoName" = "testing" ] ; then
   echo "Repo Name     : $repoName"
else
   echo "Repo Name must be specified: stable | testing"
   exit 1
fi

fullPackageName="$packageName$us$version$us$release$us$architecture"
configFolder="$destinationFolder/$fullPackageName/etc/$packageName/"
appInstallationFolder="$destinationFolder/$fullPackageName/usr/lib/$packageName"
debianFolder="$destinationFolder/$fullPackageName/DEBIAN"

echo "Full Package Name : $fullPackageName"

rm -r $destinationFolder/$fullPackageName
mkdir -p $configFolder
cp -r $sourceFolder/appsettings*.json $configFolder
mkdir -p $appInstallationFolder
rsync -av --exclude 'appsettings*.json' $sourceFolder/ $appInstallationFolder
chmod 777 "$appInstallationFolder/SkittlesVending.EdgeServer"


mkdir -p $debianFolder
rm deb/$repoName/$fullPackageName.deb

echo "Package: $packageName
Version: $version-$release
Maintainer: Design to Production <support@d-p.com.au>
Depends:
Architecture: amd64
Homepage: http://d-p.com.au
Description: Skittles Edge Server Application" \
> $debianFolder/control

dpkg-deb --build $destinationFolder/$fullPackageName deb/$repoName/$fullPackageName.deb

dpkg-sig -k design-to-production --sign repo deb/$repoName/$fullPackageName.deb
