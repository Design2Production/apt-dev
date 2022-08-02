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

configFolder="/etc/$packageName/"
destinationConfigFolder="$destinationFolder/$fullPackageName$configFolder"

dataFolder="/var/lib/$packageName/"
destinationDataFolder="$destinationFolder/$fullPackageName$dataFolder"

cacheFolder="/var/cache/$packageName/"
destinationCacheFolder="$destinationFolder/$fullPackageName$cacheFolder"
appInstallationFolder="$destinationFolder/$fullPackageName/usr/lib/$packageName"
debianFolder="$destinationFolder/$fullPackageName/DEBIAN"

echo "Full Package Name : $fullPackageName"

rm -r $destinationFolder/$fullPackageName

mkdir -p $destinationConfigFolder
cp -r $sourceFolder/setting.json $destinationConfigFolder

mkdir -p $destinationDataFolder
cp -r $sourceFolder/data.json $destinationDataFolder

mkdir -p $destinationCacheFolder

mkdir -p $appInstallationFolder
rsync -av --exclude --exclude 'setting.json' --exclude 'data.json' $sourceFolder/ $appInstallationFolder
chmod 777 "$appInstallationFolder/DeviceProxy"


mkdir -p $debianFolder
rm deb/$fullPackageName.deb

echo "Package: $packageName
Version: $version-$release
Maintainer: Design to Production <support@d-p.com.au>
Depends:
Architecture: amd64
Homepage: http://d-p.com.au
Description: DP Device Proxy Application" \
> $debianFolder/control

echo "${configFolder}setting.json
${dataFolder}data.json" \
> $debianFolder/conffiles

dpkg-deb --build $destinationFolder/$fullPackageName deb/$fullPackageName.deb
