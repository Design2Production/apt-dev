#!/bin/bash
#set -x #echo on
echo "Install dp-device-proxy.service ..."
echo

hardwareConfiguration="$1"
remoteServer="$2"
serviceFolder="/etc/systemd/system/"
us="_"

if [ "$hardwareConfiguration" = "DPEMS-V1" ] || [ "$hardwareConfiguration" = "DPEMS-V1_DBV2" ] || [ "$hardwareConfiguration" = "DPEMS-V1_DBV3" ] || [ "$hardwareConfiguration" = "DPEMS-V1_FANEXT" ] || [ "$hardwareConfiguration" = "DPEMS-V2" ] ; then
   echo "Hardware Configuration: $hardwareConfiguration"
else
   echo "Hardware Configuration must be specified: DPEMS-V1 | DPEMS-V1_DBV2 | DPEMS-V1_DBV3 | DPEMS-V1_FANEXT | DPEMS-V2"
   exit 1
fi

if [ "$remoteServer" = "Production" ] || [ "$remoteServer" = "Staging" ] ; then
   echo "Remove Server         : $remoteServer"
else
   echo "Remove Server must be specified: production | staging"
   exit 1
fi

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

echo
echo "... completed"
