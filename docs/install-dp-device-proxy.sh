#!/bin/bash
#set -x #echo on
echo "Install dp-device-proxy ..."
echo

releaseName="$1"
remoteServer="$2"
hardwareConfiguration="$3"
installation="$4"
newDeviceId="$5"
repoName="dpems"
aptRepo="apt-dev"
serviceFolder="/etc/systemd/system/"
us="_"

if [ "$repoName" = "dpems" ] ; then
   echo "Repo                  : $repoName"
else
   echo "Repo must be specified: dpems"
   exit 1
fi

if [ "$releaseName" = "stable" ] || [ "$releaseName" = "testing" ] ; then
   echo "Release Name          : $releaseName"
else
   echo "Release Name must be specified: stable | testing"
   exit 1
fi

if [ "$remoteServer" = "Production" ] || [ "$remoteServer" = "Staging" ] ; then
   echo "Remove Server         : $remoteServer"
else
   echo "Remove Server must be specified: Production | Staging"
   exit 1
fi

if [ "$hardwareConfiguration" = "DPEMS-V1" ] || [ "$hardwareConfiguration" = "DPEMS-V1_DBV2" ] || [ "$hardwareConfiguration" = "DPEMS-V1_DBV3" ] || [ "$hardwareConfiguration" = "DPEMS-V1_FANEXT" ] || [ "$hardwareConfiguration" = "DPEMS-V2" ] ; then
   echo "Hardware Configuration: $hardwareConfiguration"
else
   echo "Hardware Configuration must be specified: DPEMS-V1 | DPEMS-V1_DBV2 | DPEMS-V1_DBV3 | DPEMS-V1_FANEXT | DPEMS-V2"
   exit 1
fi

if [ "$aptRepo" = "apt" ] || [ "$aptRepo" = "apt-dev" ] ; then
   echo "Apt Repo              : $aptRepo"
else 
   echo "Apt Repo must be specified: apt | apt-dev"
   exit 1
fi

if [ -z "$installation" ] ; then
   echo "Old Installation must be specified new | oldInstallationDirectory"
   exit 1
else
   echo "Installation          : $installation"
   if [ "$installation" != "new" ] ; then
      settingFile="$installation/conf/setting.json"
      dataFile="$installation/data/data.json"
      if [ ! -f $settingFile ] ; then
         echo "setting.json does not exist in old Installation folder $settingFile"
         exit 1
      fi
      if [ ! -f $dataFile ] ; then
         echo "data.json does not exist in old Installation folder $dataFile"
         exit 1
      fi
   else
      if [ -z "$newDeviceId" ] ; then
         echo "newDeviceId must be specified"
         exit 1
      fi
   fi
fi

# write out environment so the update routine can read it
echo '{
   "server": "Linux'"$remoteServer"'"
}' \
> /var/lib/dp-device-proxy/server.json

echo "Get and install dp key ..."

rm -f /tmp/dp-key.gpg
wget -P /tmp -nc https://design2production.github.io/$aptRepo/dp-key.gpg
install -o root -g root -m 644 /tmp/dp-key.gpg /etc/apt/trusted.gpg.d/

echo "... done."

echo "Setup dp $aptRepo repo..."

if [ "$aptRepo" = "apt" ] ; then
   fileName="$repoName-$releaseName.list"
fi
if [ "$aptRepo" = "apt-dev" ] ; then
   fileName="dev-$repoName-$releaseName.list"
fi

url="https://design2production.github.io/$aptRepo/lists/$fileName"

rm -f /etc/apt/sources.list.d/$fileName
wget -P /etc/apt/sources.list.d -nc $url
apt update
echo "... done."

echo "Install dp-device-proxy via apt..."
apt install dp-device-proxy -y -o Dpkg::Options::="--force-confold"
echo "... done."

if [ "$installation" = "new" ] ; then
   port='/dev/ttyUSB0'
   daughterBoardPort='/dev/ttyUSB1'
   deviceAddress='http://192.168.64.3:8000'
   deviceId="$newDeviceId"
   lcdTurnOnSchedule=''
   lcdTurnOffSchedule=''
   deviceInfoPollerScheduler='* * * * *'
   enableRemoteCommand='true'
else
   #copy settings from old installation
   port="$(grep -Po '"'"port"'"\s*:\s*"\K([^"]*)' $settingFile)"
   daughterBoardPort="$(grep -Po '"'"daughterBoardPort"'"\s*:\s*"\K([^"]*)' $settingFile)"
   deviceAddress="$(grep -Po '"'"deviceAddress"'"\s*:\s*"\K([^"]*)' $settingFile)"
   deviceId="$(grep -Po '"'"deviceId"'"\s*:\s*"\K([^"]*)' $settingFile)"
   lcdTurnOnSchedule="$(grep -Po '"'"LcdTurnOnSchedule"'"\s*:\s*"\K([^"]*)' $settingFile)"
   lcdTurnOffSchedule="$(grep -Po '"'"LcdTurnOffSchedule"'"\s*:\s*"\K([^"]*)' $settingFile)"
   deviceInfoPollerScheduler="$(grep -Po '"'"DeviceInfoPollerScheduler"'"\s*:\s*"\K([^"]*)' $settingFile)"
   enableRemoteCommand="$(grep -Po '"'"enableRemoteCommand"'"\s*:\s*"\K([^"]*)' $settingFile)"
   cp -fr $dataFile /var/lib/dp-device-proxy/data.json
fi
echo "write settings.json"
echo '{
   "port": "'"$port"'",
   "daughterBoardPort": "'"$daughterBoardPort"'",
   "deviceAddress": "'"$deviceAddress"'",
   "deviceId": "'"$deviceId"'",
   "LcdTurnOnSchedule": "'"$lcdTurnOnSchedule"'",
   "LcdTurnOffSchedule": "'"$lcdTurnOffSchedule"'",
   "DeviceInfoPollerScheduler": "'"$deviceInfoPollerScheduler"'",
   "enableRemoteCommand": "'"$enableRemoteCommand"'",
   "secondPcIpAddress": ""
}' \
> /etc/dp-device-proxy/setting.json

echo "Install dp-device-proxy.service..."

echo "[Unit]
    Description=DeviceProxy

    [Service]
    WorkingDirectory=/usr/lib/dp-device-proxy
    ExecStart=/usr/lib/dp-device-proxy/DeviceProxy
    Restart=always
    RestartSec=10   
    SyslogIdentifier=dp-device-proxy
    Environment=ASPNETCORE_ENVIRONMENT=Linux$remoteServer$us$hardwareConfiguration

    [Install]
    WantedBy=multi-user.target" \
> $serviceFolder/dp-device-proxy.service

systemctl daemon-reload

echo "... done."

echo "enable and start dp-device-proxy.service"

systemctl enable dp-device-proxy.service
systemctl start dp-device-proxy.service

echo
echo "Installation Complete."
