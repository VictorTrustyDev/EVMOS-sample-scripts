#!/bin/bash

source ../env.sh

CHAIN_NO=$1
export DOCKER_IMAGE_NAME=$DOCKER_IMAGE_NAME_PREFIX''$CHAIN_NO

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Going to build docker image $DOCKER_IMAGE_NAME for chain $CHAIN_1_ID"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Going to build docker image $DOCKER_IMAGE_NAME for chain $CHAIN_2_ID"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

docker-compose -f "network$CHAIN_NO.yml" down

# Check EVMOS source
if [ -d "./$EVMOS_SOURCE_DIR" ]; then
    echo "EVMOS repo was downloaded"
else
    echo "Downloading EVMOS source code $EVMOS_VER"
    git clone https://github.com/evmos/evmos.git --branch $EVMOS_VER --single-branch $EVMOS_SOURCE_DIR

    if [ $? -ne 0 ]; then
        echo "Git clone EVMOS $EVMOS_VER failed"
        exit 1
    fi
fi

VAL_HOME_PREFIX='.'$DENOM_SYMBOL'd'$CHAIN_NO
VAL_HOME_1=$VAL_HOME_PREFIX'0'
VAL_HOME_2=$VAL_HOME_PREFIX'1'
VAL_HOME_3=$VAL_HOME_PREFIX'2'

# Remove previous image
docker rmi "$DOCKER_IMAGE_NAME"

# Docker build
docker build -t "$DOCKER_IMAGE_NAME" -f "Dockerfile$CHAIN_NO" .

echo "Image: $DOCKER_IMAGE_NAME"
echo 'Done, you can move to next step'