#!/bin/bash

EVMOS_SOURCE_DIR="./EVMOS-source-code-$EVMOS_VER"

if [ -f "$BINARY" ]; then
	echo "Nice! EVMOS binary $EVMOS_BINARY is already exists"
else
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

    CUR_DIR=$(pwd)
	cd "$EVMOS_SOURCE_DIR"
	echo "Compiling $EVMOS_BINARY. If this is the first time you compile, it will take time, you can enjoy a cup of coffee and comeback later"
    make install
    [ $? -eq 0 ] || { echo "Failed to compile EVMOS"; exit 1; }
    cd "$CUR_DIR"
fi

if [ ! -f "$BINARY" ]; then
    echo "EVMOS source code was compiled but binary $EVMOS_BINARY could not be found"
    echo "You must find it and put it into PATH environment variable"
    echo "(It usually compile and moved to $GOPATH/bin)"
    exit 1
fi