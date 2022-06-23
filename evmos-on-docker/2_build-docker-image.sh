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
    export PORT_26657="$EVMOS_CHAIN_1_PORT_RPC"
    export PORT_9090="$EVMOS_CHAIN_1_PORT_GRPC"
    export PORT_8545="$EVMOS_CHAIN_1_PORT_JSON_RPC"
    export PORT_1317="$EVMOS_CHAIN_1_PORT_REST_API"
    export PORT_26656="$EVMOS_CHAIN_1_PORT_P2P"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Network 2"
    export PORT_26657="$EVMOS_CHAIN_2_PORT_RPC"
    export PORT_9090="$EVMOS_CHAIN_2_PORT_GRPC"
    export PORT_8545="$EVMOS_CHAIN_2_PORT_JSON_RPC"
    export PORT_1317="$EVMOS_CHAIN_2_PORT_REST_API"
    export PORT_26656="$EVMOS_CHAIN_2_PORT_P2P"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

export DOCKER_IMAGE_NAME=$DOCKER_IMAGE_NAME_PREFIX''$CHAIN_NO
DOCKER_COMPOSE_FILE="network$CHAIN_NO.yml"

if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    docker-compose -f "$DOCKER_COMPOSE_FILE" down
fi

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

# Remove previous image
echo "Remove previous docker image $DOCKER_IMAGE_NAME"
docker rmi "$DOCKER_IMAGE_NAME"

# Docker build
echo "Build new docker image $DOCKER_IMAGE_NAME"
docker build -t "$DOCKER_IMAGE_NAME" -f "Dockerfile$CHAIN_NO" --build-arg "SRC_DIR=$EVMOS_SOURCE_DIR" .
[ $? -eq 0 ] || { echo "Failed to build docker image"; exit 1; }

# Create docker-compose yml
DOCKER_COMPOSE_FILE="network$CHAIN_NO.yml"
echo "Creating docker compose file: $DOCKER_COMPOSE_FILE"
cp template.networkX.yml "$DOCKER_COMPOSE_FILE"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/_p_chain_no_/$CHAIN_NO/g" "$DOCKER_COMPOSE_FILE"
    sed -i '' "s/_p_26657_/$PORT_26657/g" "$DOCKER_COMPOSE_FILE"
    sed -i '' "s/_p_9090_/$PORT_9090/g" "$DOCKER_COMPOSE_FILE"
    sed -i '' "s/_p_8545_/$PORT_8545/g" "$DOCKER_COMPOSE_FILE"
    sed -i '' "s/_p_1317_/$PORT_1317/g" "$DOCKER_COMPOSE_FILE"
    sed -i '' "s/_p_26656_/$PORT_26656/g" "$DOCKER_COMPOSE_FILE"
    sed -i '' "s/_p_image_prefix_/$DOCKER_IMAGE_NAME_PREFIX/g" "$DOCKER_COMPOSE_FILE"
else
    sed -i "s/_p_chain_no_/$CHAIN_NO/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_26657_/$PORT_26657/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_9090_/$PORT_9090/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_8545_/$PORT_8545/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_1317_/$PORT_1317/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_26656_/$PORT_26656/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_image_prefix_/$DOCKER_IMAGE_NAME_PREFIX/g" "$DOCKER_COMPOSE_FILE"
fi
echo '- Expose ports:'
echo "+ 26657 => $PORT_26657"
echo "+ 9090 => $PORT_9090"
echo "+ 8545 => $PORT_8545"
echo "+ 1317 => $PORT_1317"
echo "+ 26658 => $PORT_26656"

# Finish
echo 'Done'
echo 'You can start them now'
echo "$ docker-compose -f $DOCKER_COMPOSE_FILE up -d"
