#!/bin/bash

source ../env.sh

CON1='evmosd0'
CON2='evmosd1'
CON3='evmosd2'

docker rm -f $CON1
docker rm -f $CON2
docker rm -f $CON3

docker run -it \
    --name $CON1 \
    -p 26656:26656 \
    -p 26657:26657 \
    -p 1317:1317 \
    -p 8545:8545 \
    -p 9090:9090 \
    -e NODE=0 \
    $DOCKER_IMAGE_NAME

docker run -it \
    --name $CON2 \
    -e NODE=1 \
    $DOCKER_IMAGE_NAME

docker run -it \
    --name $CON3 \
    -e NODE=2 \
    $DOCKER_IMAGE_NAME