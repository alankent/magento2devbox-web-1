FROM php:7.0.16-fpm

MAINTAINER "Magento"

RUN mkdir /install

# Install some commonly used commands.
ADD install/utilities.sh /install
RUN bash -c /install/utilities.sh

# Create a 'magento2' account
ADD install/create-magento2-user.sh /install
RUN bash -c /install/create-magento2-user.sh

# Add Unison
ADD install/unison.sh /install
RUN bash -c /install/unison.sh

# Set up PHP
#ENV PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=magento2 --with-fpm-group=magento2"
ADD install/php.sh /install
RUN bash -c /install/php.sh

# Install NodeJS, Gulp, Grunt, ...
ADD install/nodejs.sh /install
RUN bash -c /install/nodejs.sh

# Install Apache
ADD install/apache.sh /install
RUN bash -c /install/apache.sh

# Apache config
ADD conf/apache-default.conf /etc/apache2/sites-enabled/apache-default.conf

# PHP config
ADD conf/php.ini /usr/local/etc/php

# php-fpm config
RUN rm -r /usr/local/etc/php-fpm.d/*
ADD conf/php-fpm-magento2.conf /usr/local/etc/php-fpm.d/php-fpm-magento2.conf

# Add mysql command line properties file
ADD conf/my.cnf /home/magento2/.my.cnf

# SSH config
RUN mkdir /var/run/sshd
#RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
COPY conf/sshd_config /etc/ssh/sshd_config
RUN chown magento2:magento2 /etc/ssh/ssh_config

# supervisord config
ADD conf/supervisord.conf /etc/supervisord.conf

# unison script
ADD conf/.unison/magento2.prf /home/magento2/.unison/magento2.prf

# Add Magento cloud CLI
RUN curl -sS https://accounts.magento.cloud/cli/installer -o /home/magento2/installer

# XDebug on/off scripts
RUN mkdir -p /home/magento2/bin
ADD conf/xdebug-on /home/magento2/bin
ADD conf/xdebug-off /home/magento2/bin

# Remove all generated files
ADD conf/clean-generated /home/magento2/bin

ENV PATH $PATH:/home/magento2/scripts/:/home/magento2/.magento-cloud/bin:/var/www/magento2/bin

ENV WEBROOT_PATH /var/www/magento2

# Magento initialization helper scripts
COPY scripts/ /home/magento2/scripts/
RUN sed -i 's/^/;/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
 && cd /home/magento2/scripts \
 && composer install \
 && chmod +x /home/magento2/scripts/m2init \
 && sed -i 's/^;;*//' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Fix up Magento directory file ownerships.
RUN chown -R magento2:magento2 /home/magento2 \
 && chown -R magento2:magento2 /var/www/magento2 \
 && chmod 755 /home/magento2/scripts/bin/magento-cloud-login


ADD conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80 22 5000 44100
WORKDIR /home/magento2

USER root
ENV SHELL /bin/bash

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
