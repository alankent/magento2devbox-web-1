#!/bin/bash

sudo -u magento2 sh -c '/usr/local/bin/unison -socket 5000 2>&1 >/dev/null' &

# Create auth.json from any provided environment variables.
AUTHFILE=/home/magento2/.composer/auth.json
if [[ ! -f $AUTHFILE ]] && [[ -n $MAGENTO_PUBLIC_KEY ]]; then

    sudo -u magento2 sh -c "mkdir -p `dirname $AUTHFILE`"
    sudo -u magento2 sh -c "cat > $AUTHFILE" <<EOF
{
    "http-basic": {
        "repo.magento.com": {
            "username": "$MAGENTO_PUBLIC_KEY",
            "password": "$MAGENTO_PRIVATE_KEY"
        }
    }
}
EOF

fi

supervisord -n -c /etc/supervisord.conf
