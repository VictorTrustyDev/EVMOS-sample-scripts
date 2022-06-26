#!/bin/bash

SOURCE_CODE_DIR="./source-code-$DENOM_SYMBOL-$GIT_BRANCH"

# If the repo is different with config, show a warning
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
        echo "ERR: Git clone $CHAIN_NAME branch $GIT_BRANCH failed"
        exit 1
    fi
fi

CUR_DIR=$(pwd)
cd "$SOURCE_CODE_DIR"
echo "Compiling '$DAEMON_BINARY_NAME'. If this is the first time you compile, it will take time, you can enjoy a cup of coffee and comeback later"
make install
[ $? -eq 0 ] || { echo >&2 "ERR: Failed to compile $DAEMON_BINARY_NAME"; exit 1; }
cd "$CUR_DIR"

if [ ! -f "$BINARY" ]; then
    echo "ERR: Chain's source code was compiled but binary '$DAEMON_BINARY_NAME' could not be found"
    echo "You must find it and put it into PATH environment variable"
    echo "(It usually compile and moved to $GOPATH/bin)"
    exit 1
fi