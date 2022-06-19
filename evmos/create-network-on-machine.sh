#!/bin/bash

KEYALGO="eth_secp256k1"

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
    cd ../
fi

BINARY="$GOPATH/bin/$EVMOS_BINARY"
if [ ! -f "$BINARY" ]; then
    echo "EVMOS source code was compiled but binary $EVMOS_BINARY could not be found"
    echo "You must find it and put it into PATH environment variable"
    echo "(It usually compile and moved to $GOPATH/bin)"
    exit 1
fi

# Update environment variable for future use
export EVMOS_HOME="$HOME/.$EVMOS_BINARY-v-$CHAIN_ID"
export EVMOS_SERVICE_NAME=$EVMOS_BINARY'-svc-'$CHAIN_NO

# Stop service if exists
[ $DISABLE_SYSTEMCTL -eq 0 ] && { echo "Stopping $EVMOS_SERVICE_NAME service"; sudo systemctl stop $EVMOS_SERVICE_NAME; }

# Cleanup
echo 'Clean up previous setup'
rm -rf "$EVMOS_HOME/config"
rm -rf "$EVMOS_HOME/keyring*"

# Init chain
echo "Network home: $EVMOS_HOME"
echo "Set keyring-backend to $KEYRING"
$BINARY config keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY config chain-id $CHAIN_ID --home $EVMOS_HOME
$BINARY init $EVMOS_MONIKER'-'$KEY1 --chain-id $CHAIN_ID --home $EVMOS_HOME

# Import validator keys
#echo "*** Decrypt password: $VAL_KEYS_FILE_DECRYPT_PASSWORD"
#$BINARY keys import "$VAL_1_KEY_NAME" ../keys/validator1.key --keyring-backend $KEYRING --home $EVMOS_HOME
#echo "*** Decrypt password: $VAL_KEYS_FILE_DECRYPT_PASSWORD"
#$BINARY keys import "$VAL_2_KEY_NAME" ../keys/validator2.key --keyring-backend $KEYRING --home $EVMOS_HOME
#echo "*** Decrypt password: $VAL_KEYS_FILE_DECRYPT_PASSWORD"
#$BINARY keys import "$VAL_3_KEY_NAME" ../keys/validator3.key --keyring-backend $KEYRING --home $EVMOS_HOME
echo "Copying validator keys from ../keys/keyring to $EVMOS_HOME/keyring-$KEYRING"
pwd
cp -r ../keys/keyring/ "$EVMOS_HOME/keyring-$KEYRING"

echo 'Verifing keys'
[ "$VAL_1_ADDR" == $($BINARY keys show $VAL_1_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_1_KEY_NAME has address $VAL_1_ADDR"; exit 1; }
[ "$VAL_2_ADDR" == $($BINARY keys show $VAL_2_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_2_KEY_NAME has address $VAL_2_ADDR"; exit 1; }
[ "$VAL_3_ADDR" == $($BINARY keys show $VAL_3_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_3_KEY_NAME has address $VAL_3_ADDR"; exit 1; }

APP_TOML="$EVMOS_HOME/config/app.toml"
APP_TOML_TMP="$EVMOS_HOME/config/tmp_app.toml"
echo "Updating file $APP_TOML"
# Enable API
cat $APP_TOML | tomlq '.api["enable"]=true' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
# Enable swagger for API
cat $APP_TOML | tomlq '.api["swagger"]=true' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML

GENESIS_JSON="$EVMOS_HOME/config/genesis.json"
GENESIS_JSON_TMP="$EVMOS_HOME/config/tmp_genesis.json"
echo "Updating file $GENESIS_JSON"
# Change denom metadata
cat $GENESIS_JSON | jq '.app_state["bank"]["denom_metadata"] += [{"description": "The native EVM, governance and staking token of the '$EVMOS_CHAINNAME' Hub", "denom_units": [{"denom": "'$MIN_DENOM_SYMBOL'", "exponent": 0}, {"denom": "'$DENOM_SYMBOL'", "exponent": 18, "aliases": []}],"base": "'$MIN_DENOM_SYMBOL'", "display": "'$DENOM_SYMBOL'", "name": "'$DENOM_SYMBOL'", "symbol": "'$DENOM_SYMBOL'"}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON

echo "Done"