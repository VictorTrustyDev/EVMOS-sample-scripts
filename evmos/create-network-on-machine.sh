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

BINARY="$GOPATH/bin/$EVMOS_BINARY"
# Check & Install evmosd binary if not exists
if [ -f "$BINARY" ]; then
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
    [ $? -eq 0 ] || { echo "Failed to compile EVMOS"; exit 1; }
    cd ../
fi

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
[ $DISABLE_SYSTEMCTL -eq 0 ] && { echo "Stopping $EVMOS_SERVICE_NAME service"; sudo systemctl stop $EVMOS_SERVICE_NAME; sudo systemctl disable $EVMOS_SERVICE_NAME; }

# Cleanup
echo 'Clean up previous setup'
rm -rf "$EVMOS_HOME/config"
rm -rf "$EVMOS_HOME/keyring*"

# Init chain
echo "Network home: $EVMOS_HOME"
echo "Set keyring-backend to $KEYRING"
$BINARY config keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY config chain-id $CHAIN_ID --home $EVMOS_HOME
$BINARY init $EVMOS_MONIKER'-'$VAL_1_KEY_NAME --chain-id $CHAIN_ID --home $EVMOS_HOME

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
## Verify
echo 'Verifing keys'
[ "$VAL_1_ADDR" == $($BINARY keys show $VAL_1_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_1_KEY_NAME has address $VAL_1_ADDR"; exit 1; }
[ "$VAL_2_ADDR" == $($BINARY keys show $VAL_2_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_2_KEY_NAME has address $VAL_2_ADDR"; exit 1; }
[ "$VAL_3_ADDR" == $($BINARY keys show $VAL_3_KEY_NAME --keyring-backend $KEYRING --home $EVMOS_HOME --address) ] || { echo "Expect validator name $VAL_3_KEY_NAME has address $VAL_3_ADDR"; exit 1; }

# Update app.toml
APP_TOML="$EVMOS_HOME/config/app.toml"
APP_TOML_TMP="$EVMOS_HOME/config/tmp_app.toml"
APP_TOML_BAK="$EVMOS_HOME/config/bak_app.toml"
echo "Backup $APP_TOML into $APP_TOML_BAK for future use"
cp $APP_TOML $APP_TOML_BAK
echo "Updating file $APP_TOML"
## Enable API
cat $APP_TOML | tomlq '.api["enable"]=true' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
## Enable swagger for API
cat $APP_TOML | tomlq '.api["swagger"]=true' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML


# Update genesis.json
GENESIS_JSON="$EVMOS_HOME/config/genesis.json"
GENESIS_JSON_TMP="$EVMOS_HOME/config/tmp_genesis.json"
echo "Updating file $GENESIS_JSON"
## Change denom metadata
cat $GENESIS_JSON | jq '.app_state["bank"]["denom_metadata"] += [{"description": "The native EVM, governance and staking token of the '$EVMOS_CHAINNAME' Hub", "denom_units": [{"denom": "'$MIN_DENOM_SYMBOL'", "exponent": 0}, {"denom": "'$GAS_DENOM_SYMBOL'", "exponent": '$EVMOS_GAS_DENOM_EXPONENT'}, {"denom": "'$DENOM_SYMBOL'", "exponent": '$EVMOS_DENOM_EXPONENT'}],"base": "'$MIN_DENOM_SYMBOL'", "display": "'$DENOM_SYMBOL'", "name": "'$DENOM_SYMBOL'", "symbol": "'$DENOM_SYMBOL'"}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Change parameter token denominations to *min denom symbol (eg aevmos)*
cat $GENESIS_JSON | jq '.app_state["staking"]["params"]["bond_denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
cat $GENESIS_JSON | jq '.app_state["crisis"]["constant_fee"]["denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
cat $GENESIS_JSON | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
cat $GENESIS_JSON | jq '.app_state["evm"]["params"]["evm_denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
cat $GENESIS_JSON | jq '.app_state["inflation"]["params"]["mint_denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
cat $GENESIS_JSON | jq '.app_state["claims"]["params"]["claims_denom"]="'$MIN_DENOM_SYMBOL'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Set gas limit
cat $GENESIS_JSON | jq '.consensus_params["block"]["max_gas"]="10000000"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Set claims start time
current_date=$(date -u +"%Y-%m-%dT%TZ")
cat $GENESIS_JSON | jq -r --arg current_date "$current_date" '.app_state["claims"]["params"]["airdrop_start_time"]=$current_date' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Set claims records for validator account
cat $GENESIS_JSON | jq '.app_state["claims"]["claims_records"]=[{"initial_claimable_amount":"'$VAL_1_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_1_ADDR'"},{"initial_claimable_amount":"'$VAL_2_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_2_ADDR'"},{"initial_claimable_amount":"'$VAL_3_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_3_ADDR'"}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Set claims decay
cat $GENESIS_JSON | jq '.app_state["claims"]["params"]["duration_of_decay"]="2592000s"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
cat $GENESIS_JSON | jq '.app_state["claims"]["params"]["duration_until_decay"]="86400s"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
## Claim module account:
### 0xA61808Fe40fEb8B3433778BBC2ecECCAA47c8c47 || evmos15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz
amount_to_claim=$(bc <<< "$VAL_1_CLAIM + $VAL_2_CLAIM + $VAL_3_CLAIM")
cat $GENESIS_JSON | jq '.app_state["bank"]["balances"] += [{"address":"'$EVMOS_CLAIM_MODULE_ACCOUNT'","coins":[{"denom":"'$MIN_DENOM_SYMBOL'", "amount":"'$amount_to_claim'"}]}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON


# Update config.toml
CONFIG_TOML="$EVMOS_HOME/config/config.toml"
CONFIG_TOML_TMP="$EVMOS_HOME/config/tmp_config.toml"
CONFIG_TOML_BAK="$EVMOS_HOME/config/bak_config.toml"
echo "Updating file $CONFIG_TOML"
## Update seed nodes
TENDERMINT_NODE_ID=$($BINARY tendermint show-node-id --home $EVMOS_HOME)
cat $CONFIG_TOML | tomlq '.p2p["seeds"]="'$TENDERMINT_NODE_ID'@localhost:26656"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
## Disable create empty block
cat $CONFIG_TOML | tomlq '.["create_empty_blocks"]=false' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
## Backup
echo "Backup $CONFIG_TOML into $CONFIG_TOML_BAK for future use"
cp $CONFIG_TOML $CONFIG_TOML_BAK
## Expose RPC
cat $CONFIG_TOML | tomlq '.rpc["laddr"]="tcp://0.0.0.0:26657"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML

# Allocate genesis accounts
$BINARY add-genesis-account $VAL_1_KEY_NAME "$VAL_1_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY add-genesis-account $VAL_2_KEY_NAME "$VAL_2_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home $EVMOS_HOME
$BINARY add-genesis-account $VAL_3_KEY_NAME "$VAL_3_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home $EVMOS_HOME

# Update total supply + claim values in genesis.json
total_supply=$(bc <<< "$VAL_1_BALANCE + $VAL_2_BALANCE + $VAL_3_BALANCE + $VAL_1_CLAIM + $VAL_2_CLAIM + $VAL_3_CLAIM")
cat $GENESIS_JSON | jq '.app_state["bank"]["supply"][0]["amount"]="'$total_supply'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON

# Sign genesis transaction
$BINARY gentx $VAL_1_KEY_NAME "$VAL_1_STAKE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --chain-id $CHAIN_ID --home $EVMOS_HOME

# Collect genesis tx to genesis.json
$BINARY collect-gentxs --home $EVMOS_HOME

# Validate genesis.json
$BINARY validate-genesis --home $EVMOS_HOME
[ $? -eq 0 ] || { echo "Failed to validate genesis"; exit 1; }

echo "Done"

# Re-Start service
if [ $DISABLE_SYSTEMCTL -eq 0 ]; then
    SERVICE_FILE="/etc/systemd/system/$EVMOS_SERVICE_NAME.service"
    if [ -f "$SERVICE_FILE" ]; then
        echo "You are ready to restart $EVMOS_SERVICE_NAME service (sudo systemctl restart $EVMOS_SERVICE_NAME)"
    else
        read -p "Do you want to create $EVMOS_SERVICE_NAME at $SERVICE_FILE ? (Y/n)" -n 1 -r
        echo #
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            sudo echo "[Unit] $EVMOS_SERVICE_NAME chain $CHAIN_ID
Description=($EVMOS_BINARY)
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
WantedBy=multi-user.target" > $SERVICE_FILE
            sudo systemctl enable $EVMOS_SERVICE_NAME
            echo "You are ready to start $EVMOS_SERVICE_NAME service (sudo systemctl restart $EVMOS_SERVICE_NAME)"
        fi
    fi
fi

echo '##### NOTICE #####'
read -p "Do you want to run more validator?" -n 1 -r
echo #
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo 'Replacing seed IP in config.toml from localhost to '$IP_EVMOS_1_INT'... Done!'
    cat $CONFIG_TOML | tomlq '.p2p["seeds"]="'$TENDERMINT_NODE_ID'@'$IP_EVMOS_1_INT':26656"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
    cat $CONFIG_TOML_BAK | tomlq '.p2p["seeds"]="'$TENDERMINT_NODE_ID'@'$IP_EVMOS_1_INT':26656"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML_BAK
    echo "Now you need to do:"
    echo "1. Update /etc/hosts to resolve $IP_EVMOS_1_INT domain to IP of this machine (this validator was configurated to be seed node)"
    echo "2. Copy the following files to the new machine"
    echo " - $GENESIS_JSON"
    echo " - $CONFIG_TOML"
    echo "3. Update /etc/hosts of those machine to resolve the IP address of $IP_EVMOS_1_INT follow IP of this machine"
    echo "4. Run ./create-validator.sh (before that, remember to run the validator node on this machine first)"
    echo "Good luck with EVMOS"
fi