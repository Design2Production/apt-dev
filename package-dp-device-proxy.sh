#!/bin/bash shopt -s extglob
#set -x #echo on
echo "Package DeviceProxy..."
echo
packageName="dp-device-proxy"
version=$1
release=$2
architecture="amd64"
us="_"
sourceFolder="$3"
packagingFolder="Packaging"
clientName="$4"
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
   echo "Source Folder must be specified"
   exit 1
else
   echo "Source Folder    : $sourceFolder"
fi

if [ "$clientName" = "shopper-media" ] || [ "$clientName" = "internal" ] ; then
   echo "Client           : $clientName"
else
   echo "Client must be specified: shopper-media | internal"
   exit 1
fi

if [ "$repoName" = "stable" ] || [ "$repoName" = "testing" ] ; then
   echo "Repo Name     : $repoName"
else
   echo "Repo Name must be specified: stable | testing"
   exit 1
fi

fullPackageName="$packageName$us$version$us$release$us$architecture"

configFolder="/etc/$packageName/"
packagingConfigFolder="$packagingFolder/$fullPackageName$configFolder"

dataFolder="/var/lib/$packageName/"
packagingDataFolder="$packagingFolder/$fullPackageName$dataFolder"

logFolder="/var/log/$packageName/"
packagingLogFolder="$packagingFolder/$fullPackageName$logFolder"

cacheFolder="/var/cache/$packageName/"
packagingCacheFolder="$packagingFolder/$fullPackageName$cacheFolder"

serviceFolder="/etc/systemd/system/"
packagingServiceFolder="$packagingFolder/$fullPackageName$serviceFolder"

packagingAppFolder="$packagingFolder/$fullPackageName/usr/lib/$packageName"

packagingDebianFolder="$packagingFolder/$fullPackageName/DEBIAN"

destinationFolder="docs/$clientName-$repoName/amd64"

echo "Full Package Name : $fullPackageName"

rm -rf $packagingFolder/$fullPackageName

mkdir -p $destinationFolder
chmod --recursive 777 docs
rm -rf $destinationFolder/$fullPackageName.deb

mkdir -p $packagingConfigFolder
chmod 777 $packagingConfigFolder
if [ "$clientName" != "shopper-media" ] ; then
   cp -r $sourceFolder/setting.json $packagingConfigFolder
fi

mkdir -p $packagingDataFolder
chmod 777 $packagingDataFolder
cp -r $sourceFolder/data.json $packagingDataFolder

mkdir -p $packagingCacheFolder
chmod 777 $packagingCacheFolder

mkdir -p $packagingLogFolder
chmod 777 $packagingLogFolder

mkdir -p $packagingServiceFolder
cp -r $sourceFolder/dp-device-proxy.service $packagingServiceFolder

mkdir -p $packagingAppFolder
rsync -a --stats --exclude 'setting.json' --exclude 'data.json' --exclude 'dp-device-proxy.service' $sourceFolder/ $packagingAppFolder
chmod 777 "$packagingAppFolder/DeviceProxy"
chmod 777 "$packagingAppFolder/avrdude"

mkdir -p $packagingDebianFolder

rm -f deb/$fullPackageName.deb

echo "Package: $packageName
Version: $version-$release
Maintainer: Design to Production <support@d-p.com.au>
Depends:
Architecture: amd64
Homepage: http://d-p.com.au
Description: DP Device Proxy Application" \
> $packagingDebianFolder/control

if [ "$clientName" = "shopper-media" ] ; then
   echo "${dataFolder}data.json" \
   > $packagingDebianFolder/conffiles
else
   echo "${configFolder}setting.json
${dataFolder}data.json" \
   > $packagingDebianFolder/conffiles
fi

echo 'STATUS="$(systemctl is-active dp-device-proxy.service)"
if [ "$STATUS" = "active" ]; then
    systemctl stop dp-device-proxy.service
fi
exit 0' \
> $packagingDebianFolder/preinst
chmod 775 $packagingDebianFolder/preinst

echo "systemctl enable dp-device-proxy.service
systemctl start dp-device-proxy.service" \
> $packagingDebianFolder/postinst
chmod 775 $packagingDebianFolder/postinst

dpkg-deb --build $packagingFolder/$fullPackageName $destinationFolder/$fullPackageName.deb
