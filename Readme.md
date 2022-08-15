# This is the repo for apt development 
We use this for developing scripts and testing changes and updates.
Once we are happy with the functions, the changes can be copied over to the apt repo which is used for produciton distribution of our software.

# Package Creation

## WSL installation

## GPG 
gpg: all values passed to '--default-key' ignored
gpg: no default secret key: No secret key
gpg: signing failed: No secret key

If you see this error when running update-apt-repo.sh, you are running with sudo... ensure you execute as: *sh ./update-apt-repo.sh*

### Required packages
sudo apt install dpkg-dev
sudo apt install mono-utils
