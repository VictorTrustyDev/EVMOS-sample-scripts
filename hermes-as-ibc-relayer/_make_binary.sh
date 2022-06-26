#!/bin/bash

export HERMES_SOURCE_DIR="$HERMES_SOURCE_DIR_PREFIX-$HERMES_GIT_REPO_BRANCH"
# If the repo is different with config, show a warning
if [ -d "$HERMES_SOURCE_DIR" ]; then
    echo "Hermes repo exists at $HERMES_SOURCE_DIR"
    echo "Checking repo url & branch name"
    CHK_RES_1="$(git --git-dir "./$HERMES_SOURCE_DIR"/.git --work-tree "./$HERMES_SOURCE_DIR" config --get remote.origin.url)"
    if [ $? -ne 0 ] || [ -z "$CHK_RES_1" ]; then
        echo "WARN! Unable to check remote origin url of git repo at $HERMES_SOURCE_DIR"
        sleep 2s
    elif [ "$CHK_RES_1" != "$HERMES_GIT_REPO" ]; then
        echo "WARN! Git repo Url does not match"
        echo "Expected: '$HERMES_GIT_REPO'"
        echo "Actual: '$CHK_RES_1'"
        echo "You should check it (script will continue execution after 10s)"
        sleep 10s
    fi
    CHK_RES_2="$(git --git-dir "./$HERMES_SOURCE_DIR"/.git --work-tree "./$HERMES_SOURCE_DIR" rev-parse --abbrev-ref HEAD)"
    if [ $? -ne 0 ] || [ -z "$CHK_RES_2" ]; then
        echo "WARN! Unable to check branch of git repo at $HERMES_SOURCE_DIR"
        sleep 2s
    elif [ "$CHK_RES_2" = "HEAD" ]; then
        echo "WARN! Can not check branch"
    elif [ "$CHK_RES_2" != "$HERMES_GIT_REPO_BRANCH" ]; then
        echo "WARN! Git Branch does not match"
        echo "Expected: '$HERMES_GIT_REPO_BRANCH'"
        echo "Actual: '$CHK_RES_2'"
        echo "You should check it (script will continue execution after 10s)"
        sleep 10s
    fi
else
    echo "Downloading Hermes source code $HERMES_GIT_REPO_BRANCH"
    git clone "$HERMES_GIT_REPO" --branch "$HERMES_GIT_REPO_BRANCH" --single-branch "$HERMES_SOURCE_DIR"

    if [ $? -ne 0 ]; then
        echo >&2 "ERR: Git clone Hermes $HERMES_GIT_REPO_BRANCH failed"
        exit 1
    fi
fi

CUR_DIR=$(pwd)
cd "$HERMES_SOURCE_DIR"
echo "Compiling $HERMES_BINARY. If this is the first time you compile, it will take time, you can enjoy a cup of coffee and comeback later"
sleep 3s
cargo build --release --bin $HERMES_BINARY
[ $? -eq 0 ] || { echo >&2 "ERR: Failed to compile Hermes"; exit 1; }
cd "$CUR_DIR"

if [ ! -f "$BINARY" ]; then
    echo >&2 "ERR: Hermes source code was compiled but binary $HERMES_BINARY could not be found"
    exit 1
fi