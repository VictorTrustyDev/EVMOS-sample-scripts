#!/bin/bash

source ../env.sh

CHAIN_NO=$1

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Going to setup an EVMOS chain with id $CHAIN_1_ID"
    export CHAIN_ID="$CHAIN_1_ID"
    export IP_EVMOS_EXT="$IP_EVMOS_1_EXT"
    export NETWORK_PORT_OFFSET=$NETWORK_PORT_OFFSET_1
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Going to setup an EVMOS chain with id $CHAIN_2_ID"
    export CHAIN_ID="$CHAIN_2_ID"
    export IP_EVMOS_EXT="$IP_EVMOS_2_EXT"
    export NETWORK_PORT_OFFSET=$NETWORK_PORT_OFFSET_2
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

# Binary
export BINARY="$GOPATH/bin/$EVMOS_BINARY"

# Check & Install evmosd binary if not exists
./_make_binary.sh
[ $? -eq 0 ] || { echo "Failed to check & build $EVMOS_BINARY binary at $BINARY"; }

# Update environment variable for future use
EVMOS_HOME_DIR='.'$EVMOS_BINARY''$CHAIN_NO'0'
export EVMOS_HOME="$HOME/$EVMOS_HOME_DIR"
EVMOS_SERVICE_NAME_PAT=$EVMOS_BINARY''$CHAIN_NO
export EVMOS_SERVICE_NAME=$EVMOS_SERVICE_NAME_PAT'0'

# Stop service if exists
[ $DISABLE_SYSTEMCTL -eq 0 ] && { 
    echo "Stopping $EVMOS_SERVICE_NAME service";
    sudo systemctl stop $EVMOS_SERVICE_NAME;
    sudo systemctl stop $EVMOS_SERVICE_NAME_PAT'1' > /dev/null 2>&1; # Shutdown other validators
    sudo systemctl stop $EVMOS_SERVICE_NAME_PAT'2' > /dev/null 2>&1; # Shutdown other validators
    sudo systemctl disable $EVMOS_SERVICE_NAME;
}

# Cleanup
echo 'Clean up previous setup'
rm -rf "$EVMOS_HOME/config"
rm -rf "$EVMOS_HOME/data"
rm -rf "$EVMOS_HOME/keyring*"

# Init chain
echo "Node home: $EVMOS_HOME"
echo "Set keyring-backend to $KEYRING"
$BINARY config keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY config chain-id $CHAIN_ID --home $EVMOS_HOME
$BINARY init $EVMOS_MONIKER'-'$VAL_1_KEY_NAME --chain-id $CHAIN_ID --home $EVMOS_HOME > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to init chain"; exit 1; }

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
echo '- Verifing keys'
[ "$VAL_1_ADDR" == $($BINARY keys show $VAL_1_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_1_KEY_NAME has address $VAL_1_ADDR"; exit 1; }
echo " + OK: $VAL_1_KEY_NAME addr $VAL_1_ADDR seed '$VAL_1_SEED'"
[ "$VAL_2_ADDR" == $($BINARY keys show $VAL_2_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_2_KEY_NAME has address $VAL_2_ADDR"; exit 1; }
echo " + OK: $VAL_2_KEY_NAME addr $VAL_2_ADDR seed '$VAL_2_SEED'"
[ "$VAL_3_ADDR" == $($BINARY keys show $VAL_3_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_3_KEY_NAME has address $VAL_3_ADDR"; exit 1; }
echo " + OK: $VAL_3_KEY_NAME addr $VAL_3_ADDR seed '$VAL_3_SEED'"

# Ports
DEFAULT_1317=$(bc <<< "1317 + $NETWORK_PORT_OFFSET") # OK
DEFAULT_6060=$(bc <<< "6060 + $NETWORK_PORT_OFFSET") # OK
DEFAULT_8545=$(bc <<< "8545 + $NETWORK_PORT_OFFSET") # OK
DEFAULT_8546=$(bc <<< "8546 + $NETWORK_PORT_OFFSET") # OK
DEFAULT_9090=$(bc <<< "9090 + $NETWORK_PORT_OFFSET") # OK
DEFAULT_9091=$(bc <<< "9091 + $NETWORK_PORT_OFFSET") # OK
DEFAULT_26656=$(bc <<< "26656 + $NETWORK_PORT_OFFSET") # OK
DEFAULT_26657=$(bc <<< "26657 + $NETWORK_PORT_OFFSET") # OK
DEFAULT_26658=$(bc <<< "26658 + $NETWORK_PORT_OFFSET") # OK

# Update app.toml
APP_TOML="$EVMOS_HOME/config/app.toml"
APP_TOML_TMP="$EVMOS_HOME/config/tmp_app.toml"
APP_TOML_BAK="$EVMOS_HOME/config/bak_app.toml"
echo "Backup $APP_TOML into $APP_TOML_BAK for future use"
cp $APP_TOML $APP_TOML_BAK
echo "Updating app.toml"
echo '- Enable API by setting [api > enable] to "true"'
cat $APP_TOML | tomlq '.api["enable"]=true' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
echo '- Enable Swagger (access via http://host/swagger/) by setting [api > swagger] to "true"'
cat $APP_TOML | tomlq '.api["swagger"]=true' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
if [ $NETWORK_PORT_OFFSET -eq 0 ]; then
    echo "- Bind API to 0.0.0.0:1317 by updating [api > address]"
    cat $APP_TOML | tomlq '.api["address"]="tcp://0.0.0.0:1317"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
else
    echo "- Bind API to 0.0.0.0:$DEFAULT_1317 by updating [api > address]"
    cat $APP_TOML | tomlq '.api["address"]="tcp://0.0.0.0:'$DEFAULT_1317'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
    echo "- Bind gRPC to 0.0.0.0:$DEFAULT_9090 by updating [grpc > address]"
    cat $APP_TOML | tomlq '.grpc["address"]="[tcp://0.0.0.0:'$DEFAULT_9090']"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
    echo "- Bind Web-gRPC to 0.0.0.0:$DEFAULT_9091 by updating [grpc-web > address]"
    cat $APP_TOML | tomlq '."grpc-web"["address"]="tcp://0.0.0.0:'$DEFAULT_9091'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
    echo "- Bind Json-RPC to 0.0.0.0:$DEFAULT_8545 by updating [json-rpc > address]"
    cat $APP_TOML | tomlq '."json-rpc"["address"]="tcp://0.0.0.0:'$DEFAULT_8545'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
    echo "- Bind Json-RPC websocket to 0.0.0.0:$DEFAULT_8546 by updating [json-rpc > ws-address]"
    cat $APP_TOML | tomlq '."json-rpc"["ws-address"]="tcp://0.0.0.0:'$DEFAULT_8546'"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
fi

# Update genesis.json
GENESIS_JSON="$EVMOS_HOME/config/genesis.json"
GENESIS_JSON_TMP="$EVMOS_HOME/config/tmp_genesis.json"
echo "Updating genesis.json"
## Change denom metadata
echo '- Add denom metadata at [app_state > bank > denom_metadata]'
cat $GENESIS_JSON | jq '.app_state["bank"]["denom_metadata"] += [{"description": "The native EVM, governance and staking token of the '$EVMOS_CHAINNAME' Hub", "denom_units": [{"denom": "'$MIN_DENOM_SYMBOL'", "exponent": 0}, {"denom": "'$GAS_DENOM_SYMBOL'", "exponent": '$EVMOS_GAS_DENOM_EXPONENT'}, {"denom": "'$DENOM_SYMBOL'", "exponent": '$EVMOS_DENOM_EXPONENT'}],"base": "'$MIN_DENOM_SYMBOL'", "display": "'$DENOM_SYMBOL'", "name": "'$DENOM_SYMBOL'", "symbol": "'$DENOM_SYMBOL'"}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Change parameter token denominations to *min denom symbol (eg aevmos)*
echo "- Change token denomination to $MIN_DENOM_SYMBOL"
echo ' + [app_state > staking > params > bond_denom]'
cat $GENESIS_JSON | jq '.app_state["staking"]["params"]["bond_denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
echo ' + [app_state > crisis > constant_fee > denom]'
cat $GENESIS_JSON | jq '.app_state["crisis"]["constant_fee"]["denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
echo ' + [app_state > gov > deposit_params > min_deposit[0] > denom]'
cat $GENESIS_JSON | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
echo ' + [app_state > evm > params > evm_denom]'
cat $GENESIS_JSON | jq '.app_state["evm"]["params"]["evm_denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
echo ' + [app_state > inflation > params > mint_denom]'
cat $GENESIS_JSON | jq '.app_state["inflation"]["params"]["mint_denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
echo ' + [app_state > claims > params > claims_denom]'
cat $GENESIS_JSON | jq '.app_state["claims"]["params"]["claims_denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Set gas limit
CONS_BLOCK_GAS_LIMIT=10000000
echo "- Set gas limit per block in [consensus_params > block > max_gas] to $CONS_BLOCK_GAS_LIMIT"
cat $GENESIS_JSON | jq '.consensus_params["block"]["max_gas"]="'$CONS_BLOCK_GAS_LIMIT'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Set claims start time
current_date=$(date -u +"%Y-%m-%dT%TZ")
echo "- Set claim start time in [app_state > claims > params > airdrop_start_time] to $current_date"
cat $GENESIS_JSON | jq -r --arg current_date "$current_date" '.app_state["claims"]["params"]["airdrop_start_time"]=$current_date' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Set claims records for validator account
echo "- Set claim records for 3 validators in [app_state > claims > claims_records]"
echo " + Validator $VAL_1_ADDR (node 0) can claim "$(bc <<< "$VAL_1_CLAIM / (10^$EVMOS_DENOM_EXPONENT)")$DENOM_SYMBOL
echo " + Validator $VAL_2_ADDR (node 1) can claim "$(bc <<< "$VAL_2_CLAIM / (10^$EVMOS_DENOM_EXPONENT)")$DENOM_SYMBOL
echo " + Validator $VAL_3_ADDR (node 2) can claim "$(bc <<< "$VAL_3_CLAIM / (10^$EVMOS_DENOM_EXPONENT)")$DENOM_SYMBOL
cat $GENESIS_JSON | jq '.app_state["claims"]["claims_records"]=[{"initial_claimable_amount":"'$VAL_1_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_1_ADDR'"},{"initial_claimable_amount":"'$VAL_2_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_2_ADDR'"},{"initial_claimable_amount":"'$VAL_3_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_3_ADDR'"}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Set claims decay
duration_until_decay="86400s"
duration_of_decay="2592000s"
echo "- Set duration until decay in [app_state > claims > params > duration_until_decay] to $duration_until_decay"
cat $GENESIS_JSON | jq '.app_state["claims"]["params"]["duration_until_decay"]="'$duration_until_decay'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
echo "- Set duration of decay in [app_state > claims > params > duration_of_decay] to $duration_of_decay"
cat $GENESIS_JSON | jq '.app_state["claims"]["params"]["duration_of_decay"]="'$duration_of_decay'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Claim module account:
### 0xA61808Fe40fEb8B3433778BBC2ecECCAA47c8c47 || evmos15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz
amount_to_claim=$(bc <<< "$VAL_1_CLAIM + $VAL_2_CLAIM + $VAL_3_CLAIM")
echo '- Claimn module account addr '$EVMOS_CLAIM_MODULE_ACCOUNT', total '$(bc <<< "$amount_to_claim / (10^$EVMOS_DENOM_EXPONENT)")' '$DENOM_SYMBOL
cat $GENESIS_JSON | jq '.app_state["bank"]["balances"] += [{"address":"'$EVMOS_CLAIM_MODULE_ACCOUNT'","coins":[{"denom":"'$MIN_DENOM_SYMBOL'", "amount":"'$amount_to_claim'"}]}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON


# Update config.toml
CONFIG_TOML="$EVMOS_HOME/config/config.toml"
CONFIG_TOML_TMP="$EVMOS_HOME/config/tmp_config.toml"
CONFIG_TOML_BAK="$EVMOS_HOME/config/bak_config.toml"
echo "Updating config.toml"
## Update seed nodes
TENDERMINT_NODE_ID=$($BINARY tendermint show-node-id --home $EVMOS_HOME)
echo '- Add seeds [p2p > seeds]'
cat $CONFIG_TOML | tomlq '.p2p["seeds"]="'$TENDERMINT_NODE_ID'@'$IP_EVMOS_EXT':'$DEFAULT_26656'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
echo '- Remove default persistent peers at [p2p > persistent_peers]'
cat $CONFIG_TOML | tomlq '.p2p["persistent_peers"]=""' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
echo '- Save tendermint node id to be used as seeds for other nodes'
cat $CONFIG_TOML | tomlq '.p2p["seeds_id"]="'$TENDERMINT_NODE_ID'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
## Disable create empty block
echo '- Disable create empty block by setting [root > create_empty_blocks] to false'
cat $CONFIG_TOML | tomlq '.["create_empty_blocks"]=false' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
## Backup
echo "Backup $CONFIG_TOML into $CONFIG_TOML_BAK for future use"
cp $CONFIG_TOML $CONFIG_TOML_BAK
## Expose RPC
if [ $NETWORK_PORT_OFFSET -eq 0 ]; then
    echo "- Bind RPC to 0.0.0.0:26657 by updating [rpc > laddr]"
    cat $CONFIG_TOML | tomlq '.rpc["laddr"]="tcp://0.0.0.0:26657"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
else
    echo "- Bind RPC to 0.0.0.0:$DEFAULT_26657 by updating [rpc > laddr]"
    cat $CONFIG_TOML | tomlq '.rpc["laddr"]="tcp://0.0.0.0:'$DEFAULT_26657'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
    echo "- Bind RPC pprof_laddr to localhost:$DEFAULT_6060 by updating [rpc > pprof_laddr]"
    cat $CONFIG_TOML | tomlq '.rpc["pprof_laddr"]="proxy_app://127.0.0.1:'$DEFAULT_6060'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
    echo "- Bind Proxy App to localhost:$DEFAULT_26658 by updating [root > proxy_app]"
    cat $CONFIG_TOML | tomlq '.["laddr"]="proxy_app://127.0.0.1:'$DEFAULT_26658'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
    echo "- Bind Peer to localhost:$DEFAULT_26656 by updating [p2p > laddr]"
    cat $CONFIG_TOML | tomlq '.p2p["laddr"]="tcp://127.0.0.1:'$DEFAULT_26656'"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
fi

# Allocate genesis accounts
$BINARY add-genesis-account $VAL_1_KEY_NAME "$VAL_1_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY add-genesis-account $VAL_2_KEY_NAME "$VAL_2_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY add-genesis-account $VAL_3_KEY_NAME "$VAL_3_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home $EVMOS_HOME

# Update total supply + claim values in genesis.json
total_supply=$(bc <<< "$VAL_1_BALANCE + $VAL_2_BALANCE + $VAL_3_BALANCE + $VAL_1_CLAIM + $VAL_2_CLAIM + $VAL_3_CLAIM")
echo 'Update original total supply = '$(bc <<< "$total_supply / (10^$EVMOS_DENOM_EXPONENT)")' '$DENOM_SYMBOL' into [app_state > bank > supply[0] > amount]'
cat $GENESIS_JSON | jq '.app_state["bank"]["supply"][0]["amount"]="'$total_supply'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON

# Sign genesis transaction
echo 'Generate genesis staking transaction '$(bc <<< "$VAL_1_STAKE / (10^$EVMOS_DENOM_EXPONENT)")' '$DENOM_SYMBOL' for validator '$VAL_1_KEY_NAME
$BINARY gentx $VAL_1_KEY_NAME "$VAL_1_STAKE"$MIN_DENOM_SYMBOL \
    --commission-rate="$VAL_COMMISSION_RATE" \
    --commission-max-rate="$VAL_COMMISSION_RATE_MAX" \
    --commission-max-change-rate="$VAL_COMMISSION_CHANGE_RATE_MAX" \
    --min-self-delegation="$VAL_MIN_SELF_DELEGATION" \
    --keyring-backend $KEYRING \
    --chain-id $CHAIN_ID \
    --home $EVMOS_HOME > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to create genesis tx"; exit 1; }

# Collect genesis tx to genesis.json
echo "Collecting genesis tx into genesis.json"
$BINARY collect-gentxs --home $EVMOS_HOME > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to collect genesis tx"; exit 1; }

# Validate genesis.json
$BINARY validate-genesis --home $EVMOS_HOME
[ $? -eq 0 ] || { echo "Failed to validate genesis"; exit 1; }

# Backup genesis.json
GENESIS_JSON_BAK="$EVMOS_HOME/config/bak_genesis.json"
echo "Backup $GENESIS_JSON into $GENESIS_JSON_BAK for future use"
cp $GENESIS_JSON $GENESIS_JSON_BAK

echo "Done"

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
        SCRIPT_CONTENT="[Unit]
\nDescription=$EVMOS_CHAINNAME chain $CHAIN_ID node 0
\nConditionPathExists=$BINARY
\nAfter=network.target
\n[Service]
\nType=simple
\nUser=$USER
\nWorkingDirectory=$HOME
\nExecStart=$BINARY start --chain-id $CHAIN_ID --home $EVMOS_HOME
\nRestart=always
\nRestartSec=2
\n[Install]
\nWantedBy=multi-user.target"
        echo -e $SCRIPT_CONTENT
        echo
        echo "sudo systemctl enable $EVMOS_SERVICE_NAME"
        echo "sudo systemctl start $EVMOS_SERVICE_NAME"

        [ $EXTRA_FUNC -eq 1 ] && {
            echo 'Creating service '$EVMOS_SERVICE_NAME;
            echo -e $SCRIPT_CONTENT | sudo tee $SERVICE_FILE > /dev/null;
            sudo systemctl enable $EVMOS_SERVICE_NAME;
        }
    fi
fi

echo '##### NOTICE #####'
echo "You have to add file following domain \"$IP_EVMOS_EXT\" to hosts file and resolve it to IP address of this machine (can not be 127.0.0.1) because it is being used for this node becomes seed node (check config.toml [p2p > seed])"

echo
read -p "Do you want to run more validator? (Y/n)" -n 1 -r
echo #
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "!This validator was configurated to be seed node"
    echo "Now you need to do:"
    echo "1. Copy the following files to the new machine"
    echo " - $GENESIS_JSON_BAK"
    echo " - $CONFIG_TOML_BAK"
    echo "2. Update /etc/hosts of those machine to resolve the IP address of domain \"$IP_EVMOS_EXT\" follow IP of this machine"
    echo "3. Run ./create-validator.sh (before that, remember to run the validator node on this machine first)"
    echo "Good luck with EVMOS"
    cp $GENESIS_JSON_BAK 'bak_genesis.json'
    cp $CONFIG_TOML_BAK 'bak_config.toml'
fi

echo
echo 'Exposed ports:'
echo "- 0.0.0.0:$DEFAULT_1317 (REST API)"
echo "- 0.0.0.0:$DEFAULT_9090 (gRPC)"
echo "- 0.0.0.0:$DEFAULT_8545 (Json RPC)"
echo "- 0.0.0.0:$DEFAULT_26657 (Tendermint RPC)"
echo "- 0.0.0.0:$DEFAULT_26656 (Peer)"
echo 'Other ports:'
echo "- 0.0.0.0:$DEFAULT_8546 (Json RPC Websocket)"
echo "- 0.0.0.0:$DEFAULT_9091 (Web-gRPC)"
echo "- localhost:$DEFAULT_6060 (RPC pprof_laddr)"
echo "- localhost:$DEFAULT_26658 (Proxy App)"

echo
echo 'Basic command to start this node:'
echo "$EVMOS_BINARY start --home ~/$EVMOS_HOME_DIR"

[ $EXTRA_FUNC -eq 1 ] && sudo systemctl start $EVMOS_SERVICE_NAME