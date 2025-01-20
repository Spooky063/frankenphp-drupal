#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
    set -- frankenphp run "$@"
fi

DB_STATUS=$(drush st --field=db-status 2>/dev/null || echo "Error")
if [ "$DB_STATUS" != "Connected" ]; then
    drush site:install \
        --account-name=admin \
        --account-pass=admin \
        --db-url=sqlite://sites/default/files/.ht.sqlite \
        --yes
fi

exec "$@"
