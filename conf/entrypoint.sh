#!/bin/bash

sudo -u magento2 sh -c '/usr/local/bin/unison -socket 5000 2>&1 >/dev/null' &

supervisord -n -c /etc/supervisord.conf
