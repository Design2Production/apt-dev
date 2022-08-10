#!/bin/bash
set -x #echo on

# NOTE: The keys have already been created for the apt-repo, so this should never need to be called again
# I have created this for reference on how I created all the keys
# We don't want to ever create new keys unless absolutley necessary, as customers that have already installed our apps using the public key would need to update to the new keys


echo "%echo Generating PGP key
Key-Type: RSA
Key-Length: 4096
Name-Real: design-to-production
Name-Email: support@d-p.com.au
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit" > /home/win/dev/apt-keys/dp-key.batch

export GNUPGHOME="$(mktemp -d /home/win/dev/apt-keys/pgpkeys-XXXXXX)"
gpg --no-tty --batch --gen-key /home/win/dev/apt-keys/dp-key.batch
gpg --armor --export-secret-keys design-to-production > /home/win/dev/apt-keys/dp-key.private
gpg --armor --export design-to-production > /home/win/dev/apt-keys/dp-key.public
cat /home/win/dev/apt-keys/dp-key.public | gpg --dearmor  > /home/win/dev/apt-keys/dp-key.gpg
cp /home/win/dev/apt-keys/dp-key.gpg docs/dp-key.gpg