#!/bin/bash

source ../env.sh

if [ $DISABLE_SYSTEMCTL -eq 0 ]; then
    echo "Stopping bdjuno-svc1 services"
    sudo systemctl stop bdjuno-svc1 > /dev/null 2>&1
    sudo systemctl disable bdjuno-svc1 > /dev/null 2>&1
    echo "Stopping bdjuno-svc2 services"
    sudo systemctl stop bdjuno-svc2 > /dev/null 2>&1
    sudo systemctl disable bdjuno-svc2 > /dev/null 2>&1
    echo "Stopping bd2-svc1 services"
    sudo systemctl stop bd2-svc1 > /dev/null 2>&1
    sudo systemctl disable bd2-svc1 > /dev/null 2>&1
    echo "Stopping bd2-svc2 services"
    sudo systemctl stop bd2-svc2 > /dev/null 2>&1
    sudo systemctl disable bd2-svc2 > /dev/null 2>&1
fi

echo 'Remove existing docker container & volumes'
docker rm -f bdjdb1 > /dev/null 2>&1
docker volume rm -f bdjdb1 > /dev/null 2>&1
docker rm -f bdjhasura1 > /dev/null 2>&1
docker rm -f bdjdb2 > /dev/null 2>&1
docker volume rm -f bdjdb2 > /dev/null 2>&1
docker rm -f bdjhasura2 > /dev/null 2>&1