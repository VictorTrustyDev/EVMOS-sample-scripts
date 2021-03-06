#!/bin/bash

command -v 'docker-compose' > /dev/null 2>&1 || { echo >&2 "ERR: docker-compose is required"; exit 1; }

source ../env.sh

if [ $DISABLE_SYSTEMCTL -eq 0 ]; then
    echo "Stopping $HERMES_SERVICE_NAME service"
    sudo systemctl stop $HERMES_SERVICE_NAME > /dev/null 2>&1
    sudo systemctl disable $HERMES_SERVICE_NAME > /dev/null 2>&1
else
    echo "I don't know what to do, this script only be used to stop hermes service name [$HERMES_SERVICE_NAME] on systems that supports 'systemd'"
fi