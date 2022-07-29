sudo echo "#!/bin/bash
apt-get update
apt-get upgrade -y -o Dpkg::Options::=\"--force-confold\"
apt-get autoclean" \
> /etc/cron.daily/dp-auto-update.sh

sudo chmod 755 /etc/cron.daily/dp-auto-update.sh