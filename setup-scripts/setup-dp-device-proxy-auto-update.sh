sudo echo "#!/bin/bash
systemctl stop dp-device-proxy.service
apt update
apt install dp-device-proxy -y -o Dpkg::Options::=\"--force-confold\"
apt autoclean
systemctl start dp-device-proxy.service" \
> /etc/cron.daily/dp-device-proxy-auto-update

sudo chmod 755 /etc/cron.daily/dp-device-proxy-auto-update