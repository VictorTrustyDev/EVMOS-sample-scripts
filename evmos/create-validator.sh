#!/bin/bash

source ../env.sh

VALIDATOR_NO=$1

# Validate input
if [ "$VALIDATOR_NO" = "2" ]; then
	export VAL_KEY_NAME="$VAL_2_KEY_NAME"
	export VAL_ADDR="$VAL_2_ADDR"
	export NODE_IDX=1
elif [ "$VALIDATOR_NO" = "3" ]; then
	export VAL_KEY_NAME="$VAL_3_KEY_NAME"
	export VAL_ADDR="$VAL_3_ADDR"
	export NODE_IDX=2
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

if [ "$CHAIN_ID" = "$CHAIN_1_ID" ]; then
	export CHAIN_NO=1
elif [ "$CHAIN_ID" = "$CHAIN_2_ID" ]; then
	export CHAIN_NO=2
else
	echo "Unable to recognize chain $CHAIN_ID, it matches neither CHAIN_1_ID='$CHAIN_1_ID' nor CHAIN_2_ID='$CHAIN_2_ID' (check ../env.sh)"
	exit 1
fi

export EVMOS_HOME="$HOME/.$EVMOS_BINARY-v-$CHAIN_ID-node$NODE_IDX"
export EVMOS_SERVICE_NAME=$EVMOS_BINARY'-n'$NODE_IDX

# Stop service if exists
[ $DISABLE_SYSTEMCTL -eq 0 ] && { echo "Stopping $EVMOS_SERVICE_NAME service"; sudo systemctl stop $EVMOS_SERVICE_NAME; sudo systemctl disable $EVMOS_SERVICE_NAME; }

$BINARY config keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY config chain-id $CHAIN_ID --home $EVMOS_HOME

# Cleanup
echo 'Clean up previous setup'
rm -rf "$EVMOS_HOME/config"
rm -rf "$EVMOS_HOME/keyring*"

# Init a pseudo chain
$BINARY init $EVMOS_MONIKER'-'$VAL_KEY_NAME --chain-id $CHAIN_ID --home $EVMOS_HOME > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to init pseudo chain"; exit 1; }

GENESIS_JSON="$EVMOS_HOME/config/genesis.json"
CONFIG_TOML="$EVMOS_HOME/config/config.toml"

# Restore genesis & config
echo "Restore genesis.json"
cp $GENSIS_JSON_BAK $GENESIS_JSON
echo "Restore config.toml"
cp $CONFIG_TOML_BAK $CONFIG_TOML

# Import validator keys
echo 'Import validator keys'
#echo "*** Decrypt password: $VAL_KEYS_FILE_DECRYPT_PASSWORD"
#$BINARY keys import "$VAL_1_KEY_NAME" ../keys/validator1.key --keyring-backend $KEYRING --home $EVMOS_HOME
#echo "*** Decrypt password: $VAL_KEYS_FILE_DECRYPT_PASSWORD"
#$BINARY keys import "$VAL_2_KEY_NAME" ../keys/validator2.key --keyring-backend $KEYRING --home $EVMOS_HOME
#echo "*** Decrypt password: $VAL_KEYS_FILE_DECRYPT_PASSWORD"
#$BINARY keys import "$VAL_3_KEY_NAME" ../keys/validator3.key --keyring-backend $KEYRING --home $EVMOS_HOME
echo "- Copying validator keys from ../keys/keyring to $EVMOS_HOME/keyring-$KEYRING"
cp -r ../keys/keyring/ "$EVMOS_HOME/keyring-$KEYRING"
## Verify
echo '- Verifing key for this node'
[ "$VAL_ADDR" == $($BINARY keys show $VAL_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_KEY_NAME has address $VAL_ADDR"; exit 1; }
echo " + $VAL_KEY_NAME: OK"

echo 'Done'

# Re-Start service
if [ $DISABLE_SYSTEMCTL -eq 0 ]; then
    SERVICE_FILE="/etc/systemd/system/$EVMOS_SERVICE_NAME.service"
	echo
    if [ -f "$SERVICE_FILE" ]; then
        echo "You are ready to restart $EVMOS_SERVICE_NAME service (sudo systemctl restart $EVMOS_SERVICE_NAME)"
    else
        echo "You can paste the following content to $SERVICE_FILE file to create a daemon service"
        echo "sudo vi $SERVICE_FILE"
        echo
        echo "[Unit]
Description=$EVMOS_CHAINNAME chain $CHAIN_ID
ConditionPathExists=$BINARY
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
ExecStart=$BINARY start --chain-id $CHAIN_ID --home $EVMOS_HOME
Restart=always
RestartSec=2
[Install]
WantedBy=multi-user.target"
        echo
        echo "sudo systemctl enable $EVMOS_SERVICE_NAME"
        echo "sudo systemctl start $EVMOS_SERVICE_NAME"
    fi
fi

echo
echo 'Basic command to start this node:'
echo "$EVMOS_BINARY start --home ~/$EVMOS_HOME_DIR"