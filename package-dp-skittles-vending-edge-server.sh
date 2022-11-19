#!/bin/bash shopt -s extglob
#set -x #echo on

executableName="SkittlesVending.EdgeServer"
packageName="dp-skittles-vending-edge-server"

echo "Package $PackageName..."
echo

architecture="amd64"
us="_"
sourceFolder="$1"
packagingFolder="Packaging"
repoName="skittles"
releaseName="$2"

if [ "$sourceFolder" = "" ] ; then
   echo "Source Folder must be specified"
   exit 1
else
   echo "Source Folder    : $sourceFolder"
fi

if [ "$repoName" = "skittles" ] ; then
   echo "Repo             : $repoName"
else
   echo "Repo must be specified: skittles"
   exit 1
fi

if [ "$releaseName" = "stable" ] || [ "$releaseName" = "testing" ] || [ "$releaseName" = "prototype" ] ; then
   echo "Release Name     : $releaseName"
else
   echo "Release Name must be specified: stable | testing | prototype"
   exit 1
fi

versionFilename="$packageName-version.txt"

rm -r $packagingFolder

rm -f $versionFilename
monodis --assembly $sourceFolder/$executableName.dll >> $versionFilename
version=$(grep 'Version:' $versionFilename | awk '{print $2}' | sed 's/\.\([^.]*\)$/-\1/')
filenameVersion=$(grep 'Version:' $versionFilename | awk '{print $2}' | sed 's/\.\([^.]*\)$/_\1/')

if [ "$version" = "" ] ; then
   echo "Version not detected in $executableName.dll"
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

mkdir -p $packagingCacheFolder
chmod 777 $packagingCacheFolder

mkdir -p $packagingLogFolder
chmod 777 $packagingLogFolder

mkdir -p $packagingAppFolder
rsync -a --info=progress2 $sourceFolder/ $packagingAppFolder
chmod 777 "$packagingAppFolder/$executableName"

mkdir -p $packagingDebianFolder

echo "Package: $packageName
Version: $version
Maintainer: Design to Production <support@d-p.com.au>
Depends:
Architecture: amd64
Homepage: http://d-p.com.au
Description: DP $executableName Application" \
> $packagingDebianFolder/control

echo 'STATUS="$(systemctl is-active '"$packageName"'.service)"
if [ "$STATUS" = "active" ]; then
    systemctl stop '"$packageName"'.service
fi
exit 0' \
> $packagingDebianFolder/preinst
chmod 775 $packagingDebianFolder/preinst

echo "systemctl enable $packageName.service
systemctl start $packageName.service" \
> $packagingDebianFolder/postinst
chmod 775 $packagingDebianFolder/postinst

dpkg-deb --build $packagingFolder/$fullPackageName $destinationFolder/$fullPackageName.deb

rm -r $packagingFolder
