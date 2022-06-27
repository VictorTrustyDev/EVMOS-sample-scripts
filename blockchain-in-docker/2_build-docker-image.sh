#!/bin/bash

command -v docker > /dev/null 2>&1 || { echo >&2 "ERR: docker is required"; exit 1; }
command -v 'docker-compose' > /dev/null 2>&1 || { echo >&2 "ERR: docker-compose is required"; exit 1; }

source ../env.sh

CHAIN_NO=$1

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

if [ -f "./_config.sh" ]; then
    source "./_config.sh"
else
    echo >&2 "ERR: Wrong working directory"
    echo >&2 "Scripts must be executed within [blockchain-in-docker] directory"
    exit 1
fi

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Chain 1"
    export PORT_26657="$CHAIN_1_EXPOSE_RPC_TO_PORT"
    export PORT_9090="$CHAIN_1_EXPOSE_GRPC_TO_PORT"
    export PORT_8545="$CHAIN_1_EXPOSE_JSON_RPC_TO_PORT"
    export PORT_1317="$CHAIN_1_EXPOSE_REST_API_TO_PORT"
    export PORT_26656="$CHAIN_1_EXPOSE_P2P_TO_PORT"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Chain 2"
    export PORT_26657="$CHAIN_2_EXPOSE_RPC_TO_PORT"
    export PORT_9090="$CHAIN_2_EXPOSE_GRPC_TO_PORT"
    export PORT_8545="$CHAIN_2_EXPOSE_JSON_RPC_TO_PORT"
    export PORT_1317="$CHAIN_2_EXPOSE_REST_API_TO_PORT"
    export PORT_26656="$CHAIN_2_EXPOSE_P2P_TO_PORT"
else
    echo >&2 'ERR: Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo >&2 'For example:'
    echo >&2 " $0 1"
    echo >&2 " or: $0 2"
    exit 1
fi

export DOCKER_IMAGE_NAME=$DOCKER_IMAGE_NAME_PREFIX''$CHAIN_NO
DOCKER_COMPOSE_FILE="network$CHAIN_NO.yml"

if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    docker-compose -f "$DOCKER_COMPOSE_FILE" down
fi

# Check source
if [ -d "$SOURCE_CODE_DIR" ]; then
    echo "$CHAIN_NAME repo exists at $SOURCE_CODE_DIR"
    echo "Checking repo url & branch name"
    CHK_RES_1="$(git --git-dir "./$SOURCE_CODE_DIR"/.git --work-tree "./$SOURCE_CODE_DIR" config --get remote.origin.url)"
    if [ $? -ne 0 ] || [ -z "$CHK_RES_1" ]; then
        echo "WARN! Unable to check remote origin url of git repo at $SOURCE_CODE_DIR"
        sleep 2s
    elif [ "$CHK_RES_1" != "$GIT_REPO" ]; then
        echo "WARN! Git repo Url does not match"
        echo "Expected: '$GIT_REPO'"
        echo "Actual: '$CHK_RES_1'"
        echo "You should check it (script will continue execution after 10s)"
        sleep 10s
    fi
    CHK_RES_2="$(git --git-dir "./$SOURCE_CODE_DIR"/.git --work-tree "./$SOURCE_CODE_DIR" rev-parse --abbrev-ref HEAD)"
    if [ $? -ne 0 ] || [ -z "$CHK_RES_2" ]; then
        echo "WARN! Unable to check branch of git repo at $SOURCE_CODE_DIR"
        sleep 2s
    elif [ "$CHK_RES_2" = "HEAD" ]; then
        echo "WARN! Can not check branch"
    elif [ "$CHK_RES_2" != "$GIT_BRANCH" ]; then
        echo "WARN! Git Branch does not match"
        echo "Expected: '$GIT_BRANCH'"
        echo "Actual: '$CHK_RES_2'"
        echo "You should check it (script will continue execution after 10s)"
        sleep 10s
    fi
else
    echo "Downloading $CHAIN_NAME source code $GIT_BRANCH"
    git clone "$GIT_REPO" --branch "$GIT_BRANCH" --single-branch "$SOURCE_CODE_DIR"

    if [ $? -ne 0 ]; then
        echo >&2 "ERR: Git clone $CHAIN_NAME from branch $GIT_BRANCH has failed"
        exit 1
    fi
fi

# Remove previous image
echo "Remove previous docker image $DOCKER_IMAGE_NAME"
docker rmi "$DOCKER_IMAGE_NAME"

# Create Dockerfile
DOCKER_FILE="Dockerfile$CHAIN_NO"
echo "Creating docker file: $DOCKER_FILE"
cp template.DockerfileX "$DOCKER_FILE"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s,_p_src_dir_,$SOURCE_CODE_DIR,g" "$DOCKER_FILE"
    sed -i '' "s/_p_daemon_binary_/$DAEMON_BINARY_NAME/g" "$DOCKER_FILE"
    sed -i '' "s/_p_home_prefix_/$VAL_HOME_PREFIX/g" "$DOCKER_FILE"
else
    sed -i "s,_p_src_dir_,$SOURCE_CODE_DIR,g" "$DOCKER_FILE"
    sed -i "s/_p_daemon_binary_/$DAEMON_BINARY_NAME/g" "$DOCKER_FILE"
    sed -i "s/_p_home_prefix_/$VAL_HOME_PREFIX/g" "$DOCKER_FILE"
fi

# Docker build
echo "Build new docker image $DOCKER_IMAGE_NAME"
docker build -t "$DOCKER_IMAGE_NAME" -f "$DOCKER_FILE" .
[ $? -eq 0 ] || { echo >&2 "ERR: Failed to build docker image"; exit 1; }

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
    sed -i '' "s/_p_home_prefix_/$VAL_HOME_PREFIX/g" "$DOCKER_COMPOSE_FILE"
else
    sed -i "s/_p_chain_no_/$CHAIN_NO/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_26657_/$PORT_26657/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_9090_/$PORT_9090/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_8545_/$PORT_8545/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_1317_/$PORT_1317/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_26656_/$PORT_26656/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_image_prefix_/$DOCKER_IMAGE_NAME_PREFIX/g" "$DOCKER_COMPOSE_FILE"
    sed -i "s/_p_home_prefix_/$VAL_HOME_PREFIX/g" "$DOCKER_COMPOSE_FILE"
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
echo "$ docker-compose -f \"$DOCKER_COMPOSE_FILE\" up -d"
