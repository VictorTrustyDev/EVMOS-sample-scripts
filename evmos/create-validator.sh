#!/bin/bash

source ../env.sh

VALIDATOR_NO=$1

# Validate input
if [ "$VALIDATOR_NO" = "2" ]; then
	export VAL_KEY_NAME="$VAL_2_KEY_NAME"
	export VAL_ADDR="$VAL_2_ADDR"
elif [ "$VALIDATOR_NO" = "3" ]; then
	export VAL_KEY_NAME="$VAL_3_KEY_NAME"
	export VAL_ADDR="$VAL_3_ADDR"
else
    echo 'Missing or incorrect validator no as first argument, valid input is 2 or 3'
    echo 'For example:'
    echo " $0 2"
    echo " or: $0 3"
    exit 1
fi

# Binary
export BINARY="$GOPATH/bin/$EVMOS_BINARY"

# Check & Install evmosd binary if not exists
./_make_binary.sh
[ $? -eq 0 ] || { echo "Failed to check & build $EVMOS_BINARY binary at $BINARY"; }

# Check genesis & config
GENSIS_JSON_BAK="bak_genesis.json"
CONFIG_TOML_BAK="bak_config.toml"

if [ ! -f $GENSIS_JSON_BAK ]; then
	echo "Missing file $GENSIS_JSON_BAK"
	echo "Copy the file $GENSIS_JSON_BAK file which was generated & backed up in the first node and paste it into this dir"
	echo "It can be found at ~/.evmosd-?/config/$GENSIS_JSON_BAK"
	exit 1
fi

if [ ! -f $CONFIG_TOML_BAK ]; then
	echo "Missing file $CONFIG_TOML_BAK"
	echo "Copy the $CONFIG_TOML_BAK file which was generated & backed up in the first node and paste it into this dir"
	echo "It can be found at ~/.evmosd-?/config/$CONFIG_TOML_BAK"
	exit 1
fi

CHAIN_ID=$(cat $GENSIS_JSON_BAK | jq .chain_id | head -n 1 | tr -d '"')
echo "Chain ID: $CHAIN_ID"

echo 'Done'