#!/bin/bash

# Create the 'magento2' user account.

# Abort on any error, echo what we are doing.
set -e
set -x

useradd -m -d /home/magento2 -s /bin/bash magento2
adduser magento2 sudo
echo "magento2 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
touch /etc/sudoers.d/privacy
echo "Defaults        lecture = never" >> /etc/sudoers.d/privacy
mkdir /var/www/magento2

cat <<EOF >/home/magento2/README
Source code goes under /var/www/magento2.
EOF

echo 'export PATH=${PATH}:/var/www/magento2/bin' >> /home/magento2/.bashrc
echo 'export PATH=${PATH}:${HOME}/bin' >> /home/magento2/.bashrc
echo 'export TERM=${TERM:?xterm}' >> /home/magento2/.bashrc
echo 'export COMPOSER_HOME=${HOME}/.composer' >> /home/magento2/.bashrc
echo 'export EDITOR=vi' >> /home/magento2/.bashrc
echo 'PS1=m2$\ ' >> /home/magento2/.bashrc
echo ':set ai expandtab sw=4' > /home/magento2/.vimrc

# Delete user password to connect with ssh with empty password
passwd magento2 -d

chown -R magento2:magento2 /home/magento2
