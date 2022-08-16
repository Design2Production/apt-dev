sudo echo "#!/bin/bash
apt update
apt install dp-device-proxy -y -o Dpkg::Options::=\"--force-confold\"
apt autoclean" \
> /etc/cron.daily/dp-device-proxy-auto-update

sudo chmod 755 /etc/cron.daily/dp-device-proxy-auto-update