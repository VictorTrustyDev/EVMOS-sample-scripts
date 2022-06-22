#!/bin/bash

source ../env.sh

if [ $DISABLE_SYSTEMCTL -eq 0 ]; then
    echo "Stopping bdjuno-svc1 services"
    sudo systemctl stop bdjuno-svc1
    sudo systemctl disable bdjuno-svc1
    echo "Stopping bdjuno-svc2 services"
    sudo systemctl stop bdjuno-svc2
    sudo systemctl disable bdjuno-svc2
fi

echo 'Remove existing docker container & volumes'
docker rm -f bdjdb1
docker volume rm -f bdjdb1
docker rm -f bdjhasura1
docker rm -f bdjdb2
docker volume rm -f bdjdb2
docker rm -f bdjhasura2