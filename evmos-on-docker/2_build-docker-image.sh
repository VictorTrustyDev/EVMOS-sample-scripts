#!/bin/bash

command -v docker > /dev/null 2>&1 || { echo >&2 "docker is required"; exit 1; }
command -v 'docker-compose' > /dev/null 2>&1 || { echo >&2 "docker-compose is required"; exit 1; }

source ../env.sh

CHAIN_NO=$1

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

if [ -f "./_config.sh" ]; then
    source "./_config.sh"
else
    echo "ERR: Wrong working directory"
    echo "ERR: Scripts must be executed within [evmos-on-docker] directory"
    exit 1
fi

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Network 1"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Network 2"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

export DOCKER_IMAGE_NAME=$DOCKER_IMAGE_NAME_PREFIX''$CHAIN_NO

echo "Going to build docker image $DOCKER_IMAGE_NAME for chain $CHAIN_ID"

docker-compose -f "network$CHAIN_NO.yml" down

# Check EVMOS source
if [ -d "$EVMOS_SOURCE_DIR" ]; then
    echo "EVMOS repo was downloaded"
else
    echo "Downloading EVMOS source code $EVMOS_VER"
    git clone "$EVMOS_REPO" --branch "$EVMOS_VER" --single-branch "$EVMOS_SOURCE_DIR"

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
docker build --build-arg "evmos_src_dir=$EVMOS_SOURCE_DIR" -t "$DOCKER_IMAGE_NAME" -f "Dockerfile$CHAIN_NO" .

echo "Image: $DOCKER_IMAGE_NAME"
echo 'Done, you can start them now'
echo '$ docker-compose -f network'$CHAIN_NO'.yml up -d'
