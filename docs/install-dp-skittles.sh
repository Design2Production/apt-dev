#!/bin/bash
#set -x #echo on
echo "Install dp-skittles ..."
echo

releaseName="$1"
applicationName="dp-skittles"
executableName="Skittles.x86_64"
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

echo "Install $applicationName via apt..."
apt install $applicationName -y -o Dpkg::Options::="--force-confold"
echo "... done."

# create the folder for the config files
mkdir -p /etc/$applicationName

#create settings files and open for editing
echo "Creating skittles-config.json for new installation..."
echo '{
  "binsToDisable": [ "" ],
  "diagnosticMode": "true",
  "binsAutoActivation": "false",
  "binsMaxHeight": "44"
}' \
> /etc/$applicationName/skittles-config.json

echo "Editing skittles-config.json in nano - Save file and exit nano to continue..."
nano /etc/$applicationName/skittles-config.json
echo "... skittles-config.json saved"

echo "Install $applicationName.service..."

echo '[Unit]
    Description='$executableName'
    After=multi-user.target
    After=dp-mdb-payment-processor.service
    After=dp-skittles-vending-edge-server.service

[Service]
    Environment=''"DISPLAY=:0"
    Environment="XAUTHORITY=/run/user/1000.mutter-Xwaylandauth.HAQIS1"
    Environment="XDG_RUNTIME_DIR=/run/user/1000"
    Environment="PULSE_RUNTIME_PATH=/run/user/1000/pulse/"
    WorkingDirectory=/usr/lib/'$applicationName'
    ExecStart=/usr/lib/'$applicationName/$executableName'
    User=dp
    Restart=always
    RestartSec=10   
    SyslogIdentifier='$applicationName'
    
[Install]
    WantedBy=multi-user.target' \
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

echo "start $applicationName.service"

systemctl enable $applicationName.service
systemctl start $applicationName.service

echo "... done."

echo
echo "Installation Complete."
