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

logFolder="/var/log/$packageName/"
destinationLogFolder="$destinationFolder/$fullPackageName$logFolder"

cacheFolder="/var/cache/$packageName/"
destinationCacheFolder="$destinationFolder/$fullPackageName$cacheFolder"

serviceFolder="/etc/systemd/system/"
destinationServiceFolder="$destinationFolder/$fullPackageName$serviceFolder"

appInstallationFolder="$destinationFolder/$fullPackageName/usr/lib/$packageName"

debianFolder="$destinationFolder/$fullPackageName/DEBIAN"

echo "Full Package Name : $fullPackageName"

rm -r $destinationFolder/$fullPackageName

mkdir -p $destinationConfigFolder
chmod 666 $destinationConfigFolder
cp -r $sourceFolder/setting.json $destinationConfigFolder

mkdir -p $destinationDataFolder
chmod 666 $destinationDataFolder
cp -r $sourceFolder/data.json $destinationDataFolder

mkdir -p $destinationCacheFolder
chmod 666 $destinationCacheFolder

mkdir -p $destinationLogFolder
chmod 666 $destinationLogFolder

mkdir -p $destinationServiceFolder
cp -r $sourceFolder/dp-device-proxy.service $destinationServiceFolder

mkdir -p $appInstallationFolder
rsync -av --exclude 'setting.json' --exclude 'data.json' --exclude 'dp-device-proxy.service' $sourceFolder/ $appInstallationFolder
chmod 777 "$appInstallationFolder/DeviceProxy"
chmod 777 "$appInstallationFolder/avrdude"

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

echo "systemctl stop dp-device-proxy.service" \
> $debianFolder/preinst
chmod 775 $debianFolder/preinst

echo "systemctl enable dp-device-proxy.service \
systemctl start dp-device-proxy.service" \
> $debianFolder/postinst
chmod 775 $debianFolder/postinst


dpkg-deb --build $destinationFolder/$fullPackageName deb/$fullPackageName.deb
