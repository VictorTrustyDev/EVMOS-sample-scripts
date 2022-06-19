#!/bin/bash

source ../env.sh

CHAIN_NO=$1

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Going to setup an EVMOS chain with id $CHAIN_1_ID"
    export CHAIN_ID="$CHAIN_1_ID"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Going to setup an EVMOS chain with id $CHAIN_2_ID"
    export CHAIN_ID="$CHAIN_2_ID"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

# Check & Install evmosd binary if not exists
if [ -f "$EVMOS_BINARY" ]; then
	echo "Nice! EVMOS binary $EVMOS_BINARY is already exists"
else
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

	cd "./$EVMOS_SOURCE_DIR"
	echo "Compiling $EVMOS_BINARY. If this is the first time you compile, it will take time, you can enjoy a cup of coffee and comeback later"
    make install
    if [ $? -ne 0 ]; then
        echo "Failed to compile EVMOS"
        exit 1
    fi
fi

BINARY="$GOPATH/bin/$EVMOS_BINARY"
if [ ! -f "$EVMOS_BIN_GO" ]; then
    echo "EVMOS source code was compiled but binary $EVMOS_BINARY could not be found"
    echo "You must find it and put it into PATH environment variable"
    echo "(It usually compile and moved to $GOPATH/bin)"
    exit 1
fi

# Update environment variable for future use
EVMOS_HOME="$HOME/.$EVMOS_BINARY-v-$CHAIN_ID"

# Cleanup
echo 'Clean up previous setup'
rm -rf "$EVMOS_HOME/config"

echo "Done"