# Design To Production - Skittles build, package, deploy, install and update information
## Skittles

### MDB
Stop, disable and delete the old mdb installation
<pre>
sudo systemctl stop PaymentProc.service
sudo systemctl disable PaymentProc.service
sudo rm /etc/systemd/system/PaymentProc.service
</pre>
Then delete the old MDB folder on the desktop

## Installation

To install the D2P device proxy repo on your PC you need to get the following file from the apt-dev repo
<pre>
wget https://design2production.github.io/apt-dev/install-dp-mdb-payment-processor.sh
</pre>

If you get an error about wget not being able to verify the github.io certificates, ensure the certificates are installed and being used for wget
<pre>
sudo apt install ca-certificates
printf "\nca_directory=/etc/ssl/certs" | sudo tee -a /etc/wgetrc
</pre>

Next execute the installation script
<pre>
sudo sh ./install-dp-mdb-payment-processor.sh stable|testing 
</pre>

The arguments being passed in are:

Release:
- stable
- testing

Use the arguments based on the device you are installing the proxy on.

For new feature development as well as pre-production testing

***testing*** should be used

For production machine installation

***stable*** should be used 

Once the installation script is completed, you can check that the new proxy is running by executing

<pre>
sudo systemctl status dp-mdb-payment-processor.service
</pre>

And you should see something like
<pre>
● dp-mdb-payment-processor.service - MdbPaymentProcessor.WebApi
   Loaded: loaded (/etc/systemd/system/dp-mdb-payment-processor.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2022-08-15 16:30:58 AEST; 19h ago
 Main PID: 3487 (DeviceProxy)
    Tasks: 23 (limit: 4569)
   CGroup: /system.slice/dp-mdb-payment-processor.service
           └─3487 /usr/lib/dp-mdb-payment-processor/MdbPaymentProcessor.WebApi

</pre>

Along with some additional recent logs.

The installation automatically adds a daily cron job to check for and automatically update the proxy at 3am to the latest published version. To check it has been correctly added to the cron system
<pre>
run-parts --test /etc/cron.daily
</pre>
And the output list should contain
<pre>
/etc/cron.daily/dp-mdb-payment-processor
</pre>
