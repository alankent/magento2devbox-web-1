#/bin/bash

# Install PHP

# Abort on any error, echo what we are doing.
set -e
set -x

export PHP_EXTRA_CONFIGURE_ARGS="--enable-fpm --with-fpm-user=magento2 --with-fpm-group=magento2"
docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
docker-php-ext-configure hash --with-mhash
docker-php-ext-install -j$(nproc) mcrypt intl xsl gd zip pdo_mysql opcache soap bcmath json iconv dom mbstring
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
pecl install xdebug
docker-php-ext-enable xdebug

cat <<EOF >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
xdebug.remote_enable=1
xdebug.remote_port=9000
xdebug.remote_connect_back=0
xdebug.remote_host=127.0.0.1
xdebug.idekey=PHPSTORM
xdebug.max_nesting_level=1000
EOF

chmod 666 /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
