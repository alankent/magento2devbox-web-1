#!/bin/bash

# Install NodeJS, Gulp, Grunt, ...

# Abort on any error, echo what we are doing.
set -e
set -x

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y python-software-properties
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install -y nodejs
npm update -g npm
npm install -g grunt-cli
npm install -g gulp
