#!/bin/bash

SOURCE_CODE_DIR="./source-code-$DENOM_SYMBOL-$GIT_BRANCH"

if [ -f "$BINARY" ]; then
	echo "Nice! Daemon binary $DAEMON_BINARY_NAME is already exists"
else
	if [ -d "$SOURCE_CODE_DIR" ]; then
		echo "$CHAIN_NAME repo was downloaded"
	else
		echo "Downloading $CHAIN_NAME source code $GIT_BRANCH"
		git clone "$GIT_REPO" --branch "$GIT_BRANCH" --single-branch "$SOURCE_CODE_DIR"

		if [ $? -ne 0 ]; then
            echo "Git clone EVMOS $GIT_BRANCH failed"
            exit 1
        fi
	fi

    CUR_DIR=$(pwd)
	cd "$SOURCE_CODE_DIR"
	echo "Compiling $DAEMON_BINARY_NAME. If this is the first time you compile, it will take time, you can enjoy a cup of coffee and comeback later"
    make install
    [ $? -eq 0 ] || { echo "Failed to compile EVMOS"; exit 1; }
    cd "$CUR_DIR"
fi

if [ ! -f "$BINARY" ]; then
    echo "Chain's source code was compiled but binary $DAEMON_BINARY_NAME could not be found"
    echo "You must find it and put it into PATH environment variable"
    echo "(It usually compile and moved to $GOPATH/bin)"
    exit 1
fi