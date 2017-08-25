#!/bin/bash

# Install Apache

# Abort on any error, echo what we are doing.
set -e
set -x

export DEBIAN_FRONTEND=noninteractive
apt-get install -y apache2
a2enmod rewrite
a2enmod proxy
a2enmod proxy_fcgi
rm -f /etc/apache2/sites-enabled/000-default.conf
sed -i 's/www-data/magento2/g' /etc/apache2/envvars
