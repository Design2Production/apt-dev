#!/bin/bash shopt -s extglob
set -x #echo on
echo "Package DeviceProxy..."
echo
packageName="$1"
version=$2
release=$3
architecture="amd64"
us="_"
sourceFolder="$4"
destinationFolder="CodeForPackaging"

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

fullPackageName="$packageName$us$version$us$release$us$architecture"
configFolder="$destinationFolder/$fullPackageName/etc/$packageName/"
dataFolder="$destinationFolder/$fullPackageName/var/lib/$packageName/"
cacheFolder="$destinationFolder/$fullPackageName/var/cache/$packageName/"
appInstallationFolder="$destinationFolder/$fullPackageName/usr/lib/$packageName"
debianFolder="$destinationFolder/$fullPackageName/DEBIAN"

echo "Full Package Name : $fullPackageName"

rm -r $destinationFolder/$fullPackageName

mkdir -p $configFolder
cp -r $sourceFolder/setting.json $configFolder

mkdir -p $dataFolder
cp -r $sourceFolder/data.json $dataFolder

mkdir -p $cacheFolder

mkdir -p $appInstallationFolder
rsync -av --exclude 'appsettings*.json' --exclude 'setting.json' --exclude 'data.json' $sourceFolder/ $appInstallationFolder
chmod 777 "$appInstallationFolder/DeviceProxy"


mkdir -p $debianFolder
rm deb/$fullPackageName.deb

echo "Package: $packageName
Version: $version
Maintainer: Design to Production <support@d-p.com.au>
Depends:
Architecture: amd64
Homepage: http://d-p.com.au
Description: DP Device Proxy Application" \
> $debianFolder/control

dpkg-deb --build $destinationFolder/$fullPackageName deb/$fullPackageName.deb
