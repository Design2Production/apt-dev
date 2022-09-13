#!/bin/bash
#set -x #echo on
echo "Install dp-skittles-vending-edge-server ..."
echo

releaseName="$1"
installation="$2"
applicationName="dp-skittles-vending-edge-server"
repoName="skittles"
aptRepo="apt-dev"
serviceFolder="/etc/systemd/system/"
us="_"

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

echo "Install dp-skittles-vending-edge-server via apt..."
apt install $applicationName -y -o Dpkg::Options::="--force-confold"
echo "... done."

#create settings files and open for editing
echo "Creating device-key.json for new installation..."
echo '{
   "deviceKey": ""
}' \
> /etc/$applicationName/device-key.json

echo "Editing device-key..json in nano - Save file and exit nano to continue..."
nano /etc/$applicationName/device-key.json
echo "... device-key.json saved"

echo "Creation machine-address.json for new installation..."
echo '{
   "machineAddress": "http://192.168.0.28:8000"
}' \
> /etc/$applicationName/machine-address.json

echo "Editing machine-address.json in nano - Save file and exit nano to continue..."
nano /var/lib/$applicationName/machine-address.json
echo "... machine-address.json saved"
echo "... done"

echo "Install $applicaitonName.service..."

echo "[Unit]
    Description=SkittlesVending.EdgeServer

    [Service]
    WorkingDirectory=/usr/lib/$applicationName
    ExecStart=/usr/lib/$applicaitonName/DeviceProxy
    Restart=always
    RestartSec=10   
    SyslogIdentifier=$applicaitonName
    
    [Install]
    WantedBy=multi-user.target" \
> $serviceFolder/$applicationName.service

systemctl daemon-reload

echo "... done."

echo "Setup $applicationName-auto-update..."
rm -f /etc/cron.daily/$applicaitonName-auto-update
echo "#!/bin/bash
apt update
apt install $applicaitonName -y -o Dpkg::Options::=\"--force-confold\"
apt autoclean" \
> /etc/cron.daily/$applicationName-auto-update

chmod 755 /etc/cron.daily/$applicationName-auto-update

echo "... done."

echo
echo "Installation Complete."
