# Design To Production
## apt-repo

### To install the D2P device proxy repo on your PC you need to get the following files for the apt-dev repo
<pre>wget https://design2production.github.io/apt-dev/get-and-install-dev-dp-key.sh</pre>
<pre>wget https://design2production.github.io/apt-dev/setup-dev-dp-apt-repo.sh</pre>
<pre>wget https://design2production.github.io/apt-dev/install-dp-device-proxy-service.sh</pre>
<pre>wget https://design2production.github.io/apt-dev/setup-dp-device-proxy-auto-update.sh</pre>
<pre>wget https://design2production.github.io/apt-dev/setting.json</pre>

### If you get an error about wget not being able to verify the github.io certificates, ensure the certificates are installed and being used for wget
sudo apt install ca-certificates

<pre>printf "\nca_directory=/etc/ssl/certs" | sudo tee -a /etc/wgetrc</pre>

### Next execute each script with:
<pre>sudo sh ./get-and-install-dev-dp-key.sh</pre>
<pre>sudo sh ./setup-dev-dp-apt-repo.sh dpems stable|testing</pre>
<pre>sudo sh ./install-dp-device-proxy-service.sh DPEMS-V1|DPEMS-V1_DBV2|DPEMS-V1_DBV3|DPEMS-V1_FANEXT|DPEMS-V2 Production|Staging</pre>
<pre>sudo sh ./setup-dp-device-proxy-auto-update.sh</pre>

### Edit the setting.json file being sure to set the deviceId, deviceAddress or port and other parameters as required
<pre>sudo nano setting.json</pre>

### Copy the setting.json file to the /etc/dp-device-proxy folder
<pre>sudo mkdir -p /etc/dp-device-proxy</pre>
<pre>sudo cp setting.json /etc/dp-device-proxy</pre>

### Then install the device proxy applicaiton
<pre>sudo apt install dp-device-proxy</pre>



