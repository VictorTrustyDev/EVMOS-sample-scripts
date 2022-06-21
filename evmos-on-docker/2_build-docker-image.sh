#!/bin/bash

source ../env.sh

docker-compose down

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

VAL_HOME_PREFIX='.evmosdn'
VAL_HOME_1=$VAL_HOME_PREFIX'0'
VAL_HOME_2=$VAL_HOME_PREFIX'1'
VAL_HOME_3=$VAL_HOME_PREFIX'2'

# Remove previous image
docker rmi "$DOCKER_IMAGE_NAME"

# Docker build
docker build -t "$DOCKER_IMAGE_NAME" .

echo "Image: $DOCKER_IMAGE_NAME"
echo 'Done, you can move to next step'