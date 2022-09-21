# This is the repo for apt development 
We use this for developing scripts and testing changes and updates.
Once we are happy with the functions, the changes can be copied over to the apt repo which is used for produciton distribution of our software.

# Package Creation

## WSL installation

## GPG 
> gpg: all values passed to '--default-key' ignored  
> gpg: no default secret key: No secret key  
> gpg: signing failed: No secret key

If you see this error when running update-apt-repo.sh, you are running with sudo... ensure you execute as: *sh ./update-apt-repo.sh*

### Required packages
> sudo apt install dpkg-dev  
> sudo apt install mono-utils

## New file locaitons on linux intsallations

### Configuration files
All the configuration files for skittles and skittles-vending-edge-server live in the /etc/dp-skittles folder

> /etc/dp-skittles/skittles-config.json  
> /etc/dp-skittles/device-config.json  
> /etc/dp-skittles/machine-address-config.json  

### Applications
All the applications live in the /usr/lib/ folder, with sub folders for each application

> /usr/lib/dp-skittles  
> /usr/lib/dp-skittles-vending-edge-server  
> /usr/lib/dp-mdb-payment-processor

### Services
All the applications now run via a linux service, with the service files located in etc/systemd/system

> /etc/systemd/system/dp-skittles.service  
> /etc/systemd/system/dp-skittles-vending-edge-server.service  
> /etc/systemd/system/dp-mdb-payment-processor.service

### Auto Update Scripts

> /etc/cron.daily/dp-skittles-auto-update  
> /etc/cron.daily/dp-skittles-skittles-vending-edge-server-auto-update  
> /etc/cron.daily/dp-mdb-payment-processor-auto-update

### Cache
Any cache files for our applications live in the /var/cache folder, with sub folders for each application
Currently, only the edge server caches files

> /var/cache/dp-skittles-vending-edge-server

### Logs
All log files for our applications live in the /var/log folder, with sub folders for each application

> /var/log/dp-skittles.service  
> /var/log/dp-skittles-vending-edge-server.service  
> /var/log/dp-mdb-payment-processor.service

## Build, Package, Deploy and Install or Update
The process for building, packaging and deploying our apps is broken down into 3 steps

### Build
Each app is built and publishes the build output to the WSL filesystem for packaging.
For the .NET applications (mdb and edge server). the publish commands publish the output directly to the wsl folder which is 

#### IMPORTANT - Each new build to be packaged and deployed MUST have a new build number

> \\wsl.localhost\Ubuntu-20.04\home\win\dev\vs-builds\skittles-vending-edge-server  
> \\wsl.localhost\Ubuntu-20.04\home\win\dev\vs-builds\mdb-payment-processor

For the Skittles Unity Applications, the build process requires you to select a local folder to build to, and then it copies the build output to

> \\wsl.localhost\Ubuntu-20.04\home\win\dev\vs-builds\skittles

### Package
The packaging process uses script files in the apt-dev repo (name will probably be changed once we debug and are ready to take the system live)

Clone the apt-dev repo to \\wsl.localhost\Ubuntu-20.04\home\win\dev which will then put the repo in \\wsl.localhost\Ubuntu-20.04\home\win\dev\apt-dev

You then package each application to the testing repo using the following command lines

> sh ./package-dp-skittles-vending-edge-server.sh ../vs-builds/skittles-vending-edge-server/ testing  
> sh ./package-dp-mdb-payment-processor.sh ../vsbuilds/mdb-payment-processor/ testing  
> sh ./package-dp-skittles.sh ../vs-builds/skittles testing

### Deploy

Once the new package(s) have been created, the apt-dev package list musy be updated. This is done through a single script for the repo

> sh ./update-apt-repo.sh skittles testing

Once the script has run, the changes must be committed and pushed to the apt-dev repo

In VS Code, use the SOURCE CONTROL panel to commit and push the changes. Include the new versions in the commit name if possible

#### IMPORTANT - Once pushed, it will take several minutes for the changes to be published to the github pages site

To know when it's publioshed, you can open the repo here

https://github.com/Design2Production/apt-dev1

Then you can click on the cross, tick or dot to the left of the commit number The status can then be seen in the popup

You can also click on the Details link, which gives you more information about the progress of the deployment

<img src="github publish status.png"
     alt="github publish status"/>

### Install Update

On the Target machine, when installing for the first time you need to download the installation scripts

> wget -O install-dp-skittles-vending-edge-server.sh https://design2production.github.io/apt-dev/install-dp-skittles-vending-edge-server.sh  
> wget -O install-dp-skittles.sh https://design2production.github.io/apt-dev/install-dp-skittles.sh  
> wget -O install-dp-mdb-payment-processor.sh https://design2production.github.io/apt-dev/install-dp-mdb-payment-processor.sh

#### IMPORTANT - You can simplfy this by not including the -O filename ... BUT if you already have a file downloaded, it won't overwrite it, but the newly downloaded file will have .1 added to the end of it and if you then try and run it, you will be using the previous install script

### Update

On the Target machine, update by calling the auto update script

> sudo /etc/cron.daily/dp-skittles-auto-update  
> sudo /etc/cron.daily/dp-skittles-skittles-vending-edge-server-auto-update  
> sudo /etc/cron.daily/dp-mdb-payment-processor-auto-update

