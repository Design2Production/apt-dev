#!/bin/bash
#set -x #echo on
echo "Install dp-mdb-payment-processor ..."
echo

releaseName="$1"
applicationName="dp-mdb-payment-processor"
executableName="MdbPaymentProcessor.WebApi"
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

if [ "$releaseName" = "stable" ] || [ "$releaseName" = "testing" ] || [ "$releaseName" = "prototype" ] ; then
   echo "Release Name          : $releaseName"
else
   echo "Release Name must be specified: stable | testing | prototype"
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

# add a setting.json file
echo '{
   "serialPort": "/dev/ttyS0' \
> /etc/$applicationName/setting.json

echo "Install $applicationName.service..."

echo "[Unit]
    Description=$executableName
    Before=dp-skittles.service

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

echo "start $applicationName.service"

systemctl enable $applicationName.service
systemctl start $applicationName.service

echo "... done."

echo
echo "Installation Complete."
