#!/bin/bash

source ../env.sh

CON1='vtevmosd0'
CON2='vtevmosd1'
CON3='vtevmosd2'

echo 'Removing containers'
docker rm -f $CON1
docker rm -f $CON2
docker rm -f $CON3

echo 'Removing network'
docker network rm $DOCKER_NETWORK_NAME

echo 'Remake network'
docker network create $DOCKER_NETWORK_NAME

docker run -d \
    --name $CON1 \
    --restart unless-stopped \
    --network=$DOCKER_NETWORK_NAME \
    -p 26656:26656 \
    -p 26657:26657 \
    -p 1317:1317 \
    -p 8545:8545 \
    -p 9090:9090 \
    -e NODE=0 \
    $DOCKER_IMAGE_NAME

docker run -d \
    --name $CON2 \
    --restart unless-stopped \
    --network=$DOCKER_NETWORK_NAME \
    -e NODE=1 \
    $DOCKER_IMAGE_NAME

docker run -d \
    --name $CON3 \
    --restart unless-stopped \
    --network=$DOCKER_NETWORK_NAME \
    -e NODE=2 \
    $DOCKER_IMAGE_NAME