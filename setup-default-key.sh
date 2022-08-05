#!/bin/bash
set -x #echo on

# NOTE: this can be run to setup the default key that was created in the create-keys.sh script
# Once this is setup, the UpdateAptRepo.sh file will use this default key to sign everything
# We don't want to ever create new keys unless absolutley necessary, as customers that have already installed our apps using the public key would need to update to the new keys
# We can however run this script to set our default key for signing however often is needed

export GNUPGHOME="$(mktemp -d ~/Documents/apt-keys/pgpkeys-XXXXXX)"
cat ~/Documents/apt-keys/dp-key.private | gpg --import