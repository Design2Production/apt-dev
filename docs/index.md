# Design To Production
## apt-repo

### To install the D2P device proxy repo on your PC you need to get the following files for the apt-dev repo
wget https://design2production.github.io/apt-dev/get-and-install-dev-dp-key.sh
wget https://design2production.github.io/apt-dev/setup-dev-dp-apt-repo.sh
wget https://design2production.github.io/apt-dev/install-dp-device-proxy-service.sh
wget https://design2production.github.io/apt-dev/setting.json

### Then execute each script with:
sudo sh ./get-and-install-dev-dp-key.sh
sudo sh ./setup-dev-dp-apt-repo.sh dpems stable|testing
sudo sh ./install-dp-device-proxy-service.sh DPEMS-V1|DPEMS-V1_DBV2|DPEMS-V1_DBV3|DPEMS-V1_FANEXT|DPEMS-V2 Production|Staging

### Edit the setting.json file being sure to set the deviceId, deviceAddress or port and other parameters as required
sudo nano setting.json
### Copy the setting.json file to the /etc/dp-device-proxy folder
sudo mkdir -p /etc/dp-device-proxy
sudo cp setting.json /etc/dp-device-proxy

### Then install the device proxy applicaiton
sudo apt install dp-device-proxy

### If you get an error about wget not being able to verify the github.io certificates, ensure the certificates are installed and being used for wget
sudo apt install ca-certificates
printf "\nca_directory=/etc/ssl/certs" | sudo tee -a /etc/wgetrc


