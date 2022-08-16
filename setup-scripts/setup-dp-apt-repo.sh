#!/bin/bash
#set -x #echo on

repoName="$1"
releaseName="$2"

if [ "$repoName" = "dpems" ] || [ "$repoName" = "skittles" ] ; then
   echo "Repo        : $repoName"
else
   echo "Repo must be specified: dpems | skittles"
   exit 1
fi

if [ "$releaseName" = "stable" ] || [ "$releaseName" = "testing" ] ; then
   echo "Release Name: $releaseName"
else
   echo "Release Name must be specified: stable | testing"
   exit 1
fi

fileName="$repoName-$releaseName.list"
url="https://design2production.github.io/apt/lists/$fileName"

rm /etc/apt/sources.list.d/$fileName
wget -P /etc/apt/sources.list.d -nc $url
apt-get update
