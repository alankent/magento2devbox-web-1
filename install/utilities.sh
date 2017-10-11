#!/bin/sh

# Install common utilities that developers frequently like.

# Abort on any error, echo what we are doing.
set -e
set -x

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
      apt-utils \
      sudo \
      wget \
      unzip \
      bzip2 \
      cron \
      curl \
      libmcrypt-dev \
      libicu-dev \
      libxml2-dev libxslt1-dev \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng12-dev \
      git \
      vim \
      nano \
      telnet \
      net-tools \
      openssh-server \
      supervisor \
      mysql-client \
      ocaml \
      expect \
      links \
      man
