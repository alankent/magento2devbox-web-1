# Introduction

This repository is part of Magento DevBox, a simple way to install a Magento 2
development environment. This image is NOT intended for production usage.

Please note, a previous version of DevBox included a web site with GUI to preconfigure
your installation. While useful to get going, developers still needed to understand
the underlying commands. The new DevBox has less 'magic', resulting in these instructions
being longer, but developers ended up needing to know this information regardless.

## What's in DevBox

DevBox includes the correct versions of tools that are all compatible with a
particular release of Magento. This includes:

* Apache with PHP FPM   TODO: NGINX?

TODO: It is planned to add support for Redis, Varnish, ElasticSearch, and RabbitMQ.

## General Mode of Operation

This image contains all the the software packages you will need to run Magento
preinstalled.  All of the files are hosted inside the container. If you wish to
use an IDE with the source code on your laptop/desktop, you can either use
Docker volume mounting or Unison to do a bidirectional file sync between the
container and your local file system. See the section on file syncing below
for more details.

If you are happy with a text editor such as vi or nano inside the container,
file sharing configuration is not required.

Normally you set up a container and use it for a long time, removing it only
when no longer required. Make sure you carefully read the file syncing section
before removing any containers to avoid deleting all of your work by accident.

## "Your Way is not the Normal Docker Way!"

Correct. Docker is normally used in production with the web server and database
servers in different containers. DevBox is not intended for production. Putting
the web server and database server together is for simplicity only.

# Getting Started

This section describes how to get up and going with DevBox.

## Prerequisites

* Install a recent version of Docker from http://docker.com/. Docker is available for Windows, Mac, and Linux.
* On Windows 10, you may need to turn on Hyper-V and then grant Docker access
  to the C: drive for Docker to operate correctly. This is described in the
  Docker documentation.
* If you like GUIs, you may wish to take the extra effort to install Kitematic from
  the Docker site as well.
* On Windows, it can be useful to install "Git Bash" (https://git-for-windows.github.io/).
  You can however just run git from inside the Docker container.

## Setting Up a New Environment

Normally you create a directory per project. (Developers at an system
integrator or agency may work on multiple projects at once.) A set of starter
files can be downloaded from TODO.

Review the `docker-compose.yml` file for adjustments such as preferred local
port numbers, then launch the container as follows:

    $ docker-compose up -d

To log into the container, use

    $ docker-compose exec web bash

To create a new project...
TODO: NEED TO WORK OUT DIRECTORY STRUCTURE FOR PROJECTS, WILL THAT AFFECT /var/www? Do you sync /var/www? Can you refer to files outside DOCROOT?

You can use text editors such as `vi` and `nano` inside the container directly. If you wish to use an
IDE on your desktop, you need to synchronize your local file system with the container. The default
recommendation is to use Unison. To start up Unison, run the command TODO

# Getting More Adventurous

The following goes deeper under the covers when inevitable little things go wrong.

## Creating a First Container

First, make sure Docker is correctly installed an operational. The `docker ps`
command lists running containers. There should be no containers running when
you install Docker for the first time.

    $ docker ps

From the command line, you can create a container as follows. You can use any
name for your container (allowing you to create multiple containers for different
projects).

    $ docker run --name m2 -d -p 8080:80 -p 22:22 -p 5000:5000 -v magento/devbox:2.2 (((TODO)))

Running `docker ps` will list the newly running container.

The command line options are as follows:

* `--name m2` give the container a convenient name to refer to it by.
* `-d` launches the contiainer in the background (daemon mode).
* `-p <localport>:<containport>` maps a local port number (localhost if using Hyper-V, can be a different IP address if running Docker inside VirtualBox or similar) to the port number used inside the container. For example, `-p 8080:80` allows your web browser to access `localhost:8080` which will be mapped through to port 80 inside the container.  TODO: NEED MAC INSTRUCTIONS TO AVOID LOCAL SSH DAEMONS ETC.
    * Port 80 is the web server port.
    * Port 22 is the SSH port.
    * Port 5000 is used by Unison running inside the container (see file syncing below)
* `magento/devbox:2.2` is the name and version of the container to use, to be downloaded from dockerhub.io.
* `-v <localpath>:<containerpath>` can be used to mount a local directory inside the container.

There are several directories that are recommended to be mounted as Docker
volumes so the contents of those files can be shared between containers. 
These directories are discussed below under file syncing.

You can start and stop containers using `docker stop m2` and `docker start m2`.
This can be useful if you want to jump between projects using the same port
numbers to avoid using CPU on your laptop when you are not using the container.

To create a bash shell in the container, run

    $ docker exec -it m2 bash

If you are using cygwin or similar on Windows, it may ask you to use `winpty`
in front of the `docker` command.

You will then have a Linux prompt inside the container logged on as 'magento2'.
(Note, this would normally log you on as root, but some magic in the bash login
script changes the user id to 'magento2' as a convenience.)

When you no longer need the container, you can kill and remove it. THIS WILL WIPE
ALL FILES INSIDE THE CONTAINER, LOSING ANY CHANGES FOREVER.

    $ docker kill m2
    $ docker rm m2

## Docker Compose

Docker includes support for multi-container configurations via `docker-compose`.
This tool can however also be useful with a single container as it reads all 
configuration settings from a standard `docker-compose.yml` file. You can then
start up the container with a single command without all the command line options.

    $ docker-compose up -d

All the command line arguments for port mappings and volume mounts can be in the
`docker-compose.yml` file. Here is a sample file:

    version: 2
    services:
      devbox:
        container_name: m2
	restart: always
	image: magento/devbox:2.2
	volumes:
	  #- "~/.composer:/home/magento2/.composer"
	  #- "~/.ssh:/home/magento2/.ssh"
	  #- "./shared/webroot:/home/magento2/magento2"
          #- "./shared/logs/apache2:/var/log/apache2"
          #- "./shared/logs/php-fpm:/var/log/php-fpm"
          #- "./shared/.magento-cloud:/home/magento2/.magento-cloud"
	ports:
	  - "80"
	  - "22"
	  - "5000"

You may need to create the local directories by hand (`~/.composer`, `shared`,
`shared/webroot`, `shared/logs`, etc).

## Kitematic

If you have installed Kitematic, you can do most of the above via a GUI. This can
be useful for quick experiments, but it is generally recommended to create your
own scripts or use docker-compose to create new containers with all the
correct command line options.

* To create a container, search for magento/devbox:2.2 in the search box then click "Create".
   * Kitematic will download then spin up a container with randomly generated port numbers.
   * Clicking on the square-and-arrow icon will start up a web browser automatically.
* To change the port numbers, go to the 'settings' tab for the container.
  "Apply" will save the settings and then restart the container.
* The 'Volumes' mount can be used to enable mounting of volumes locally.
* Buttons are then avaialble to stop, start, exec (create bash prompt) for the
  container.
* The cross-in-circle icon will remove the container when you are finished with
  it (deleting all files inside the container).

You can use command line commands in combination with Kitematic, but sometimes
Kitematic will not notice command line changes, requiring Kitematic to be
exited and restarted to refresh it.

# File Syncing

Many developers prefer to use a IDE such as PHP Storm for development.
Such IDEs generally work best when run on the local file system. They
cannot access the file system inside the Docker container without special
configuration.

Note that PHP Storm has special support for "remote PHP interpeters" 
via ssh. This makes source code development and debugging using PHP Storm
completely possible with running PHP Storm natively, with the web server
running inside DevBox.

There are several directories (such as log files) which you may wish to mount
for easy access. These files are generally small in number and size, so
Docker volume mounting works fine.

However, the main Magento source code is much larger and stresses the native
Docker file system mounting support. As such, you need to decide which way you
personally find best to use DevBox, as there are different pros and cons with
each of the approaches. You need to decide which approach you are going to use
before installing Magento inside the container. (Note: This problem is face
by other communities, not just Magento.)

In addition, some frontend developer tools like Gulp and Grunt rely on file
watching "iNotify" events from the file system. Volume mounting on Windows does
not support iNotify events at this time. If you plan to use these tools,
do not use native volume mounting for the Magento source code.

The following discussion focusses on the Magento code base, not the other
volume mount points.

## No Syncing

You can use DevBox by logging into the container and using a Linux text
editor such as vi or nano. (Emacs is not preinstalled.) It has the advantage of
being simple. That is, don't use an IDE.

## Docker-Sync.io

You may wish to have a look at http://docker-sync.io/, a Docker container that
supports multiple ways of syncing a file system. On Mac you may prefer to use
one of its options.

## Unison

Unison is an open source bi-diretional file syncing tool. It can be used to
sync a local file system with a remote file system over a network connection.
In the case of DevBox, the container can be considered a 'remote' server.

The advantage of Unison is all file system operations are standard. iNotify
generates all events correctly. The web server and IDE can run at full speed
as they both access local files, so performance is pretty good.

The disavantage of Unison is it is one more application to run. It can hang
at times (although it is pretty stable). There can also be a slight lag
between saving a file and it arriving on the other end.
It is however the best of a bad set of choices for Windows.

You can mount volumes

Docker supports volume mounting (the `-v` command line option, or `volumes` in
the `docker-compose.yml` file). This approach is useful but has some limitations
on MacOS and Windows. For MacOS and Windows, volume mounting can be slow for the
main Magento code base. (The Web Server will work, but run much slower than
expected.)

* MacOS: It's too slow for the Magento code base

* MacOS: The shared filesystem is not performant enough. Magento worked too slowly.

  That is why we decided to use Unison (a file synchronization tool) to keep the local (inside Docker) web root directory in sync with files in the shared directory. It works quite well, although the initial synchronization takes a few minutes.

  We decided not to put Unison on the host machine (which would allow us not to use shared directories at all) to avoid adding dependencies. The MacOS shared filesystem supports notification events, so it can be used directly.

* Windows: The shared file system does not support notification events.

  For this reason, we require a locally installed Unison file synchronization tool, so it can pick up file changes.

# Installing Magento

DevBox does not include the Magento source code. You need to add that yourself.
The following summarizes how to create a new project, get an existing project from
a GIT repository, and for use with Magento Commerce (Cloud). Different versions
of the DevBox image have been set up with different versions of PHP and MYSQL as
requried for each Magento release.

## Composer

The recommended way to install and update projects is via Composer, a PHP
package manager. Magento provides a Composer repository from which Magento
(and extensions purchased from Magento Marketplace) can be downloaded.

There is also a Magento ZIP download which is faster to download, but you will
need to use Composer to install patches or extensions, so it is recommended to
start with Composer from day 1.

Composer supports a download cache. Having this mounted to a local directory
on your laptop allows downloads to be shared betwen containers. Cached downloads
make upgrades or new installs much faster. If you do not mount a shared volume
for this directory, you cannot share the cache between containers and the cache
will be lost when the container is deleted. (There is nothing wrong with this
other than a potentiall larger network bill for downloads.)

DevBox sets the `COMPOSER_HOME` environment variable to `/home/magento2/.composer`.
If you have not run composer before, it will prompt you for a username and password.
Enter your 'public' and 'private' keys from http://marketplace.magento.com/ when
prompoted. Just be aware that an `auth.json` file holding your keys will be
saved into `~/.composer/`. You may want to share the Composer downloaded files
but have a different `auth.json` file per project by moving the `auth.json`
file into your project's home directory (but not committing this file to git
for security reasons).

The easiest thing is to do nothing - not mount a shared composer repository.

## Creating a New Project

TODO - 
 - auth.json (shared in ~/.composer?)
 - composer create-project
 - set to developer mode
 - create database
 - access via web browser

## Getting Code from a GitHub Project

TODO - git clone, create db, away you go.

## Magento Commerce

TODO - mcloud command

# The initial startup is slow - why?

Our goal was to provide maximum flexibility. The container supports multiple methods of installing Magento (new installation, from existing local Magento code, or from Magento Enterprise Cloud Edition) and multiple editions (CE, EE, B2B).

For this reason, we do not include Magento files in the Docker image, but instead use Composer to download the files on first start. This is a slower approach than other images you might find on Docker hub; however, it allows us to configure Magento to suit your needs.

We are considering embedding some of the files into the container for a faster start.

# Why do you include Redis, Varnish, Elasticsearch and RabbitMQ?

We think that you should develop as much as possible in an environment resembling a production configuration. In the majority of cases, a production configuration includes those components (Elasticsearch and RabbitMQ for Magento EE deployments).

This approach allows you to catch early issues related to incompatibility instead of finding those issues at the last moment. During Magento DevBox installation, use *Advanced Options* to choose which of these components to install.

# Cron

TODO: By default, to save batteries/energy, cron is disabled. Our experience shows, that running cron in container results in very quick draining of laptop batteries. To enable cron, you can follow the instructions in the documentation http://devdocs.magento.com/guides/v2.1/install-gde/docker/docker-commands.html.

# Contributions

Please use GitHub (TODO: INSERT URL) for issue tracking or to make contributions.

