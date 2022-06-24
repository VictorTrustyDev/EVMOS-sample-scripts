#!/bin/bash

export HERMES_SOURCE_DIR="$HERMES_SOURCE_DIR_PREFIX-$HERMES_VER"
if [ -f "$BINARY" ]; then
	echo "Nice! Hermes binary [$HERMES_BINARY] is already exists"
else
	if [ -d "$HERMES_SOURCE_DIR" ]; then
		echo "Hermes repo was downloaded"
	else
		echo "Downloading Hermes source code $HERMES_VER"
		git clone https://github.com/informalsystems/ibc-rs.git --branch $HERMES_VER --single-branch $HERMES_SOURCE_DIR

		if [ $? -ne 0 ]; then
            echo "Git clone Hermes $HERMES_VER failed"
            exit 1
        fi
	fi

    CUR_DIR=$(pwd)
	cd "$HERMES_SOURCE_DIR"
	echo "Compiling $HERMES_BINARY. If this is the first time you compile, it will take time, you can enjoy a cup of coffee and comeback later"
    sleep 3s
    cargo build --release --bin $HERMES_BINARY
    [ $? -eq 0 ] || { echo "Failed to compile Hermes"; exit 1; }
    cd "$CUR_DIR"
fi

if [ ! -f "$BINARY" ]; then
    echo "Hermes source code was compiled but binary $HERMES_BINARY could not be found"
    exit 1
fi