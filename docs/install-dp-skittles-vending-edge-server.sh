#!/bin/bash
#set -x #echo on
echo "Install dp-skittles-vending-edge-server ..."
echo

releaseName="$1"
applicationName="dp-skittles-vending-edge-server"
executableName="SkittlesVending.EdgeServer"
repoName="skittles"
aptRepo="apt-dev"
serviceFolder="/etc/systemd/system/"
us="_"
device="$2"

if [ "$repoName" = "skittles" ] ; then
   echo "Repo                  : $repoName"
else
   echo "Repo must be specified: skittles"
   exit 1
fi

if [ "$releaseName" = "stable" ] || [ "$releaseName" = "testing" ] ; then
   echo "Release Name          : $releaseName"
else
   echo "Release Name must be specified: stable | testing"
   exit 1
fi

if [ "$aptRepo" = "apt" ] || [ "$aptRepo" = "apt-dev" ] ; then
   echo "Apt Repo              : $aptRepo"
else 
   echo "Apt Repo must be specified: apt | apt-dev"
   exit 1
fi

if [ "$device" = "" ] ; then
   echo "device              : production install"
elif [ "$device" = "test" ] ; then
   echo "device              : test install"
else 
   echo "device must be specified: test | blank for production install"
   exit 1
fi

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

echo "Install $applicationName via apt..."
apt install $applicationName -y -o Dpkg::Options::="--force-confold"
echo "... done."

# create the folder for the config files
mkdir -p /etc/$applicationName

#create settings files and open for editing
echo "Creating device-config.json for new installation..."
if [ "$device" = "test" ] ; then
   echo '{
   "deviceId": "SK-TEST-0001",
   "deviceKey": "zSXxFlDhreSjxsaHq0fVW5E2NqBtnTPlafKu11w7sTf8Giy7+lFtAgJfUbdYqYPykrNC1Ml567C3DOnflJ73y3R6Je+S0u5869B3ustvDFM4Qt336Y5/aNDaUBajzcI/Hyk31inZqQzwB+5+ctW3gUOujB2ggyz41Yey+LwdMF1W22pVT9evs4NDJEvkVzi1EABNRKCp4E3uNKAHt+QeeQ=="
}' \
> /etc/$applicationName/device-config.json
else
   echo '{
   "deviceId": "",
   "deviceKey": ""
}' \
> /etc/$applicationName/device-config.json
fi

echo "Editing device-config..json in nano - Save file and exit nano to continue..."
nano /etc/$applicationName/device-config.json
echo "... device-config.json saved"

echo "Creation machine-address-config.json for new installation..."
if [ "$device" = "test" ] ; then
   echo '{
   "machineAddress": "http://192.168.0.28:8000"
}' \
> /etc/$applicationName/machine-address-config.json
else
   echo '{
   "machineAddress": ""
}' \
> /etc/$applicationName/machine-address-config.json
fi

echo "Editing machine-address.json in nano - Save file and exit nano to continue..."
nano /etc/$applicationName/machine-address-config.json
echo "... machine-address-config.json saved"
echo "... done"

echo "Install $applicationName.service..."

echo "[Unit]
    Description=$executableName

    [Service]
    WorkingDirectory=/usr/lib/$applicationName
    ExecStart=/usr/lib/$applicationName/$executableName
    Restart=always
    RestartSec=10   
    SyslogIdentifier=$applicationName
    
    [Install]
    WantedBy=multi-user.target" \
> $serviceFolder/$applicationName.service

systemctl daemon-reload

echo "... done."

echo "Setup $applicationName-auto-update..."
rm -f /etc/cron.daily/$applicationName-auto-update
echo "#!/bin/bash
systemctl stop $applicationName.service
apt update
apt install $applicationName -y -o Dpkg::Options::=\"--force-confold\"
apt autoclean
systemctl start $applicationName.service" \
> /etc/cron.daily/$applicationName-auto-update

chmod 755 /etc/cron.daily/$applicationName-auto-update

echo "... done."

echo
echo "Installation Complete."
