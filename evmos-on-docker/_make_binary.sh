#!/bin/bash

EVMOS_SOURCE_DIR="./source-code-$DENOM_SYMBOL-$SRC_VER"

if [ -f "$BINARY" ]; then
	echo "Nice! EVMOS daemon $EVMOS_DAEMON is already exists"
else
	if [ -d "$EVMOS_SOURCE_DIR" ]; then
		echo "EVMOS repo was downloaded"
	else
		echo "Downloading EVMOS source code $SRC_VER"
		git clone "$EVMOS_REPO" --branch "$SRC_VER" --single-branch "$EVMOS_SOURCE_DIR"

		if [ $? -ne 0 ]; then
            echo "Git clone EVMOS $SRC_VER failed"
            exit 1
        fi
	fi

    CUR_DIR=$(pwd)
	cd "$EVMOS_SOURCE_DIR"
	echo "Compiling $EVMOS_DAEMON. If this is the first time you compile, it will take time, you can enjoy a cup of coffee and comeback later"
    make install
    [ $? -eq 0 ] || { echo "Failed to compile EVMOS"; exit 1; }
    cd "$CUR_DIR"
fi

if [ ! -f "$BINARY" ]; then
    echo "EVMOS source code was compiled but binary $EVMOS_DAEMON could not be found"
    echo "You must find it and put it into PATH environment variable"
    echo "(It usually compile and moved to $GOPATH/bin)"
    exit 1
fi