#!/bin/bash shopt -s extglob
#set -x #echo on
echo "Package DeviceProxy..."
echo
packageName="dp-device-proxy"
architecture="amd64"
us="_"
sourceFolder="$1"
packagingFolder="Packaging"
releaseName="$2"
repoName="dpems"

if [ "$sourceFolder" = "" ] ; then
   echo "Source Folder must be specified"
   exit 1
else
   echo "Source Folder    : $sourceFolder"
fi

if [ "$repoName" = "dpems" ] || [ "$repoName" = "skittles" ] ; then
   echo "Repo             : $repoName"
else
   echo "Repo must be specified: dpems | skittles"
   exit 1
fi

if [ "$releaseName" = "stable" ] || [ "$releaseName" = "testing" ] ; then
   echo "Release Name     : $releaseName"
else
   echo "Release Name must be specified: stable | testing"
   exit 1
fi

rm -r $packagingFolder

rm -f dp-device-proxy-version.txt
monodis --assembly $sourceFolder/DeviceProxy.dll >> dp-device-proxy-version.txt
version=$(grep 'Version:' dp-device-proxy-version.txt | awk '{print $2}' | sed 's/\.\([^.]*\)$/-\1/')
filenameVersion=$(grep 'Version:' dp-device-proxy-version.txt | awk '{print $2}' | sed 's/\.\([^.]*\)$/_\1/')

if [ "$version" = "" ] ; then
   echo "Version not detected in DeviceProxy.dll"
   exit 1
else
   echo "Version          : $version"
fi

fullPackageName="$packageName$us$filenameVersion$us$architecture"

configFolder="/etc/$packageName/"
packagingConfigFolder="$packagingFolder/$fullPackageName$configFolder"

dataFolder="/var/lib/$packageName/"
packagingDataFolder="$packagingFolder/$fullPackageName$dataFolder"

logFolder="/var/log/$packageName/"
packagingLogFolder="$packagingFolder/$fullPackageName$logFolder"

cacheFolder="/var/cache/$packageName/"
packagingCacheFolder="$packagingFolder/$fullPackageName$cacheFolder"

packagingAppFolder="$packagingFolder/$fullPackageName/usr/lib/$packageName"

packagingDebianFolder="$packagingFolder/$fullPackageName/DEBIAN"

destinationFolder="docs/$repoName/$releaseName/amd64"

echo "Full Package Name: $fullPackageName"

rm -rf $packagingFolder/$fullPackageName

mkdir -p $destinationFolder
rm -rf $destinationFolder/$fullPackageName.deb

mkdir -p $packagingConfigFolder
chmod 777 $packagingConfigFolder

mkdir -p $packagingDataFolder
chmod 777 $packagingDataFolder
cp -r $sourceFolder/data.json $packagingDataFolder

mkdir -p $packagingCacheFolder
chmod 777 $packagingCacheFolder

mkdir -p $packagingLogFolder
chmod 777 $packagingLogFolder

mkdir -p $packagingAppFolder
rsync -a --info=progress2 --exclude 'data.json' $sourceFolder/ $packagingAppFolder
chmod 777 "$packagingAppFolder/DeviceProxy"
chmod 777 "$packagingAppFolder/avrdude"

mkdir -p $packagingDebianFolder

echo "Package: $packageName
Version: $version
Maintainer: Design to Production <support@d-p.com.au>
Depends:
Architecture: amd64
Homepage: http://d-p.com.au
Description: DP Device Proxy Application" \
> $packagingDebianFolder/control

echo "${dataFolder}data.json" \
> $packagingDebianFolder/conffiles

cp preinst $packagingDebianFolder/preinst
chmod 775 $packagingDebianFolder/preinst

cp postinst $packagingDebianFolder/postinst
chmod 775 $packagingDebianFolder/postinst

dpkg-deb --build $packagingFolder/$fullPackageName $destinationFolder/$fullPackageName.deb

#rm -r $packagingFolder
