#!/bin/bash

source ../env.sh

VALIDATOR_NO=$1

# Validate input
if [ "$VALIDATOR_NO" = "2" ]; then
	export VAL_KEY_NAME="$VAL_2_KEY_NAME"
	export VAL_ADDR="$VAL_2_ADDR"
	export VAL_STAKE="$VAL_2_STAKE"
	export NODE_IDX=1
elif [ "$VALIDATOR_NO" = "3" ]; then
	export VAL_KEY_NAME="$VAL_3_KEY_NAME"
	export VAL_ADDR="$VAL_3_ADDR"
	export VAL_STAKE="$VAL_3_STAKE"
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

EVMOS_HOME_DIR=".$EVMOS_BINARY-v-$CHAIN_ID-node$NODE_IDX"
export EVMOS_HOME="$HOME/$EVMOS_HOME_DIR"
export EVMOS_SERVICE_NAME=$EVMOS_BINARY'-c'$CHAIN_NO'-n'$NODE_IDX

# Stop service if exists
[ $DISABLE_SYSTEMCTL -eq 0 ] && { echo "Stopping $EVMOS_SERVICE_NAME service"; sudo systemctl stop $EVMOS_SERVICE_NAME; sudo systemctl disable $EVMOS_SERVICE_NAME; }

$BINARY config keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY config chain-id $CHAIN_ID --home $EVMOS_HOME

# Cleanup
echo 'Clean up previous setup'
rm -rf "$EVMOS_HOME/config"
rm -rf "$EVMOS_HOME/data"
rm -rf "$EVMOS_HOME/keyring*"

# Init a pseudo chain
MONIKER=$EVMOS_MONIKER'-'$VAL_KEY_NAME
$BINARY init $MONIKER --chain-id $CHAIN_ID --home $EVMOS_HOME > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to init pseudo chain"; exit 1; }

GENESIS_JSON="$EVMOS_HOME/config/genesis.json"
CONFIG_TOML="$EVMOS_HOME/config/config.toml"
APP_TOML="$EVMOS_HOME/config/app.toml"

# Restore genesis & config
echo "Restore genesis.json"
cp $GENSIS_JSON_BAK $GENESIS_JSON
echo "Restore config.toml"
cp $CONFIG_TOML_BAK $CONFIG_TOML

# Update port
echo 'Going to update service ports'
PORT_OFFSET=$(bc <<< "$NODE_IDX * 10 + $CHAIN_NO * 100")
echo '- Adjust with offset'
DEFAULT_1317=$(bc <<< "1317 + $PORT_OFFSET")
DEFAULT_6060=$(bc <<< "6060 + $PORT_OFFSET")
DEFAULT_8545=$(bc <<< "8545 + $PORT_OFFSET")
DEFAULT_8546=$(bc <<< "8546 + $PORT_OFFSET")
DEFAULT_9090=$(bc <<< "9090 + $PORT_OFFSET")
DEFAULT_9091=$(bc <<< "9091 + $PORT_OFFSET")
DEFAULT_26656=$(bc <<< "26656 + $PORT_OFFSET")
DEFAULT_26657=$(bc <<< "26657 + $PORT_OFFSET")
DEFAULT_26658=$(bc <<< "26658 + $PORT_OFFSET")
##
echo 'Update config.toml'
CONFIG_TOML_TMP="tmp_config.toml"
echo "- Adjust [root > proxy_app] from port 26658 to localhost:$DEFAULT_26658 (turned off by default)"
cat $CONFIG_TOML | tomlq '.["proxy_app"]="tcp://127.0.0.1:'$DEFAULT_26658'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
echo "- Adjust [rpc > laddr] from port 26657 to localhost:$DEFAULT_26657"
cat $CONFIG_TOML | tomlq '.rpc["laddr"]="tcp://127.0.0.1:'$DEFAULT_26657'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
echo "- Adjust [rpc > pprof_laddr] from port 6060 to localhost:$DEFAULT_6060"
cat $CONFIG_TOML | tomlq '.rpc["pprof_laddr"]="tcp://127.0.0.1:'$DEFAULT_6060'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
echo "- Adjust [p2p > laddr] from port 26656 to localhost:$DEFAULT_26656"
cat $CONFIG_TOML | tomlq '.p2p["laddr"]="tcp://127.0.0.1:'$DEFAULT_26656'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
SEED_ID=$(cat $CONFIG_TOML | tomlq '.p2p["seeds_id"]' | head -n 1 | tr -d '"')
if [ -z "$SEED_ID" ]; then
	echo "- [p2p > seeds_id] could not be found (this is a custom property injected by ./create-network-on-machine.sh script) so can not configure seeds properly"
else
	echo "- Configure [p2p > seeds] to connect to seed node 0 with tendermint id $SEED_ID"
	cat $CONFIG_TOML | tomlq '.p2p["seeds"]="'$SEED_ID'@'$IP_EVMOS_1_EXT':26656"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
fi

##
echo 'Update app.toml'
APP_TOML_TMP="tmp_app.toml"
echo "- Adjust [api > address] from port 1317 to localhost:$DEFAULT_1317 and turn it off by default"
cat $APP_TOML | tomlq '.api["address"]="tcp://127.0.0.1:'$DEFAULT_1317'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
cat $APP_TOML | tomlq '.api["swagger"]=false' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
cat $APP_TOML | tomlq '.api["enable"]=false' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
echo "- Adjust [grpc > address] from port 9090 to localhost:$DEFAULT_9090 and turn it off by default"
cat $APP_TOML | tomlq '.grpc["address"]="tcp://127.0.0.1:'$DEFAULT_9090'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
cat $APP_TOML | tomlq '.grpc["enable"]=false' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
echo "- Adjust [grpc-web > address] from port 9091 to localhost:$DEFAULT_9091 and turn it off by default"
cat $APP_TOML | tomlq '."grpc-web"["address"]="tcp://127.0.0.1:'$DEFAULT_9091'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
cat $APP_TOML | tomlq '."grpc-web"["enable"]=false' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
echo "- Adjust [json-rpc > address] from port 8545 to localhost:$DEFAULT_8545, [json-rpc > ws-address] from port 8546 to localhost:$DEFAULT_8546 and turn it off by default"
cat $APP_TOML | tomlq '."json-rpc"["address"]="tcp://127.0.0.1:'$DEFAULT_8545'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
cat $APP_TOML | tomlq '."json-rpc"["ws-address"]="tcp://127.0.0.1:'$DEFAULT_8546'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
cat $APP_TOML | tomlq '."json-rpc"["enable"]=false' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML


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

# Register node
$BINARY tx staking create-validator \
	--home="$EVMOS_HOME" \
	--keyring-backend $KEYRING \
	--amount="$VAL_STAKE"$MIN_DENOM_SYMBOL \
	--pubkey=$($BINARY tendermint show-validator --home $EVMOS_HOME) \
	--moniker="$MONIKER" \
	--chain-id="$CHAIN_ID" \
	--commission-rate="$VAL_COMMISSION_RATE" \
	--commission-max-rate="$VAL_COMMISSION_RATE_MAX" \
	--commission-max-change-rate="$VAL_COMMISSION_CHANGE_RATE_MAX" \
	--min-self-delegation="$VAL_MIN_SELF_DELEGATION" \
	--from="$VAL_KEY_NAME" \
	--node="tcp://$IP_EVMOS_1_EXT:26657"

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
Description=$EVMOS_CHAINNAME chain $CHAIN_ID node $NODE_IDX
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

echo 'Active ports:'
echo "- localhost:$DEFAULT_26657 (Tendermint RPC)"
echo "- localhost:$DEFAULT_26656 (Tendermint Peer)"
echo "- localhost:$DEFAULT_6060 (pprof_laddr, original :6060)"
echo 'Closed ports'
echo "- localhost:$DEFAULT_1317 (REST API)"
echo "- localhost:$DEFAULT_9090 (gRPC)"
echo "- localhost:$DEFAULT_9091 (Web gRPC)"
echo "- localhost:$DEFAULT_8545 (Json RPC)"
echo "- localhost:$DEFAULT_8546 (Websocket Json RPC)"
echo "- localhost:$DEFAULT_26658 (Proxy app)"
echo 'If you want to expose those ports, use nginx as reverse proxy'

[ -z "$SEED_ID" ] && { echo "ERR! No seed was configurated at config.toml"; }

echo
echo 'Basic command to start this node:'
echo "$EVMOS_BINARY start --home ~/$EVMOS_HOME_DIR"