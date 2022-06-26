#!/bin/bash

command -v docker > /dev/null 2>&1 || { echo >&2 "docker is required"; exit 1; }
command -v 'docker-compose' > /dev/null 2>&1 || { echo >&2 "docker-compose is required"; exit 1; }

source ../env.sh

CHAIN_NO=$1

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

if [ -f "./_config.sh" ]; then
    source "./_config.sh"
else
    echo "ERR: Wrong working directory"
    echo "ERR: Scripts must be executed within [blockchain-in-docker] directory"
    exit 1
fi

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Chain 1"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Chain 2"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

if [ "$CHAIN_TYPE" = "evmos" ]; then
    if [ "$HD_COINTYPE" -ne "60" ]; then
        echo "Chain type 'evmos' requires coin type 60 (check variable 'CHAIN_${CHAIN_NO}_COINTYPE')"
    fi
fi

if [ "$KEYRING" = "file" ]; then
    echo "Keyring: file"
elif [ "$KEYRING" = "test" ]; then
    echo "Keyring: test **WARNING** only use keyring-backend=test for development purpose on local machine or you must secure your cloud env by whitelist some IP addresses, otherwise someone will take all your token, even tho it's only a test env"
else
    echo "Non supported keyring mode = $KEYRING, only support 'file' & 'test'"
    exit 1
fi

# Binary
export BINARY="$GOPATH/bin/$DAEMON_BINARY_NAME"

# Check & Install evmosd binary if not exists
./_make_binary.sh
[ $? -eq 0 ] || { echo "ERR: Failed to check & build daemon binary '$DAEMON_BINARY_NAME' at $BINARY"; }

VAL_HOME_1=$VAL_HOME_PREFIX'0'
VAL_HOME_2=$VAL_HOME_PREFIX'1'
VAL_HOME_3=$VAL_HOME_PREFIX'2'

CONTAINER_PREFIX="vtevmos"$CHAIN_NO
# Cleanup
echo 'Clean up previous setup'
rm -rf $VAL_HOME_1'/'
rm -rf $VAL_HOME_2'/'
rm -rf $VAL_HOME_3'/'

# Init
echo 'Init home folders for 3 validators'
## Keyring
$BINARY config keyring-backend $KEYRING --home $VAL_HOME_1
$BINARY config keyring-backend $KEYRING --home $VAL_HOME_2
$BINARY config keyring-backend $KEYRING --home $VAL_HOME_3
## Chain ID
$BINARY config chain-id $CHAIN_ID --home $VAL_HOME_1
$BINARY config chain-id $CHAIN_ID --home $VAL_HOME_2
$BINARY config chain-id $CHAIN_ID --home $VAL_HOME_3
## Genesis
MONIKER=$MONIKER'-'$VAL_1_KEY_NAME
$BINARY init $MONIKER --chain-id $CHAIN_ID --home $VAL_HOME_1 > /dev/null 2>&1
[ $? -eq 0 ] || { echo "ERR: Failed to init chain on node 0"; exit 1; }
MONIKER=$MONIKER'-'$VAL_2_KEY_NAME
$BINARY init $MONIKER --chain-id $CHAIN_ID --home $VAL_HOME_2 > /dev/null 2>&1
[ $? -eq 0 ] || { echo "ERR: Failed to init pseudo chain for node 1"; exit 1; }
MONIKER=$MONIKER'-'$VAL_3_KEY_NAME
$BINARY init $MONIKER --chain-id $CHAIN_ID --home $VAL_HOME_3 > /dev/null 2>&1
[ $? -eq 0 ] || { echo "ERR: Failed to init pseudo chain for node 2"; exit 1; }

# Import validator keys
echo "Import validator keys for chain no $CHAIN_NO id $CHAIN_ID"
if [ "$KEYRING" = "test" ]; then
    echo "- Validator 1, key name '$VAL_1_KEY_NAME'"
    ( echo "$VAL_1_SEED"; ) | $BINARY keys add "$VAL_1_KEY_NAME" --recover --keyring-backend "test" --home "$VAL_HOME_1"
    [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
    echo "- Validator 2, key name '$VAL_2_KEY_NAME'"
    ( echo "$VAL_2_SEED"; ) | $BINARY keys add "$VAL_2_KEY_NAME" --recover --keyring-backend "test" --home "$VAL_HOME_1"
    [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
    echo "- Validator 3, key name '$VAL_3_KEY_NAME'"
    ( echo "$VAL_3_SEED"; ) | $BINARY keys add "$VAL_3_KEY_NAME" --recover --keyring-backend "test" --home "$VAL_HOME_1"
    [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
else
    if [ "$CHAIN_TYPE" = "evmos" ]; then
        echo "- Validator 1, key name '$VAL_1_KEY_NAME'"
        echo "** Due to evmos daemon bug, it is not possible to import seed & encryption password automatically at the same time, please copy & paste the following seed:"
        echo "___"
        echo "$VAL_1_SEED"
        echo "___"
        echo "and encryption password '$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD' to encrypt seed phrase"
        echo "of validator 1"
        $BINARY keys add "$VAL_1_KEY_NAME" --recover --keyring-backend "file" --home "$VAL_HOME_1"
        [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
        echo "- Validator 2, key name '$VAL_2_KEY_NAME'"
        echo "** Due to evmos daemon bug, it is not possible to import seed & encryption password automatically at the same time, please copy & paste the following seed:"
        echo "___"
        echo "$VAL_2_SEED"
        echo "___"
        echo "and encryption password '$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD' to encrypt seed phrase"
        echo "of validator 2"
        $BINARY keys add "$VAL_2_KEY_NAME" --recover --keyring-backend "file" --home "$VAL_HOME_1"
        [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
        echo "- Validator 3, key name '$VAL_3_KEY_NAME'"
        echo "** Due to evmos daemon bug, it is not possible to import seed & encryption password automatically at the same time, please copy & paste the following seed:"
        echo "___"
        echo "$VAL_3_SEED"
        echo "___"
        echo "and encryption password '$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD' to encrypt seed phrase"
        echo "of validator 3"
        $BINARY keys add "$VAL_3_KEY_NAME" --recover --keyring-backend "file" --home "$VAL_HOME_1"
        [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
    else
        echo "- Validator 1, key name '$VAL_1_KEY_NAME', encryption password: '$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD', seed phase '$VAL_1_SEED'"
        ( echo "$VAL_1_SEED"; echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD"; echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD"; ) | $BINARY keys add "$VAL_1_KEY_NAME" --recover --keyring-backend "file" --home "$VAL_HOME_1"
        [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
        echo "- Validator 2, key name '$VAL_2_KEY_NAME', encryption password: '$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD', seed phase '$VAL_2_SEED'"
        ( echo "$VAL_2_SEED"; echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD"; echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD"; ) | $BINARY keys add "$VAL_2_KEY_NAME" --recover --keyring-backend "file" --home "$VAL_HOME_1"
        [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
        echo "- Validator 3, key name '$VAL_3_KEY_NAME', encryption password: '$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD', seed phase '$VAL_3_SEED'"
        ( echo "$VAL_3_SEED"; echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD"; echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD"; ) | $BINARY keys add "$VAL_3_KEY_NAME" --recover --keyring-backend "file" --home "$VAL_HOME_1"
        [ $? -eq 0 ] || { echo "ERR: Failed to import"; exit 1; }
    fi
fi

## Extract
echo '- Get wallet address'
if [ "$KEYRING" = "test" ]; then
    export VAL_1_ADDR="$($BINARY keys show $VAL_1_KEY_NAME --keyring-backend $KEYRING --home "$VAL_HOME_1" --address)"
    export VAL_2_ADDR="$($BINARY keys show $VAL_2_KEY_NAME --keyring-backend $KEYRING --home "$VAL_HOME_1" --address)"
    export VAL_3_ADDR="$($BINARY keys show $VAL_3_KEY_NAME --keyring-backend $KEYRING --home "$VAL_HOME_1" --address)"
else
    export VAL_1_ADDR="$(echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY keys show $VAL_1_KEY_NAME --keyring-backend $KEYRING --home "$VAL_HOME_1" --address)"
    export VAL_2_ADDR="$(echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY keys show $VAL_2_KEY_NAME --keyring-backend $KEYRING --home "$VAL_HOME_1" --address)"
    export VAL_3_ADDR="$(echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY keys show $VAL_3_KEY_NAME --keyring-backend $KEYRING --home "$VAL_HOME_1" --address)"
fi
echo " + $VAL_1_KEY_NAME: $VAL_1_ADDR"
echo " + $VAL_2_KEY_NAME: $VAL_2_ADDR"
echo " + $VAL_3_KEY_NAME: $VAL_3_ADDR"
echo "- Clone keys to home of other validators"
cp -r "$VAL_HOME_1/keyring-$KEYRING" "$VAL_HOME_2/"
cp -r "$VAL_HOME_1/keyring-$KEYRING" "$VAL_HOME_3/"

## Verify
ADDR_PATTERN="$ACCOUNT_PREFIX[0-9][a-z0-9]+"
if [[ $VAL_1_ADDR =~ $ADDR_PATTERN ]]; then
    echo
else
    echo "ERR: Validator 1 '$VAL_1_KEY_NAME' wallet address '$VAL_1_ADDR' does not starts with '$ACCOUNT_PREFIX', did you forget to update the 'CHAIN_"$CHAIN_NO"_ACCOUNT_PREFIX' var"
    exit 1
fi

# Calculate balance & stake & claim info for validators
## Balance
export VAL_1_BALANCE=$(bc <<< "10^$DENOM_EXPONENT * $VAL_1_RAW_BALANCE")
export VAL_2_BALANCE=$(bc <<< "10^$DENOM_EXPONENT * $VAL_2_RAW_BALANCE")
export VAL_3_BALANCE=$(bc <<< "10^$DENOM_EXPONENT * $VAL_3_RAW_BALANCE")
## Stake
export VAL_1_STAKE=$(bc <<< "10^$DENOM_EXPONENT * $VAL_1_RAW_STAKE")
export VAL_2_STAKE=$(bc <<< "10^$DENOM_EXPONENT * $VAL_2_RAW_STAKE")
export VAL_3_STAKE=$(bc <<< "10^$DENOM_EXPONENT * $VAL_3_RAW_STAKE")
## Claim
if [ $DISABLE_CLAIM -eq 0 ]; then
    export VAL_1_CLAIM=$(bc <<< "10^$DENOM_EXPONENT * $VAL_1_RAW_CLAIM")
    export VAL_2_CLAIM=$(bc <<< "10^$DENOM_EXPONENT * $VAL_2_RAW_CLAIM")
    export VAL_3_CLAIM=$(bc <<< "10^$DENOM_EXPONENT * $VAL_3_RAW_CLAIM")
else
    export VAL_1_CLAIM=0
    export VAL_2_CLAIM=0
    export VAL_3_CLAIM=0
fi

# Update genesis.json
GENESIS_JSON="$VAL_HOME_1/config/genesis.json"
GENESIS_JSON_TMP="$VAL_HOME_1/config/tmp_genesis.json"
echo "Updating genesis.json"
## Change denom metadata
echo '- Add denom metadata at [app_state > bank > denom_metadata]'
cat $GENESIS_JSON | jq '.app_state["bank"]["denom_metadata"] += [{"description": "The native EVM, governance and staking token of the '$CHAIN_NAME' Hub", "denom_units": [{"denom": "'$MIN_DENOM_SYMBOL'", "exponent": 0}, {"denom": "'$GAS_DENOM_SYMBOL'", "exponent": '$GAS_DENOM_EXPONENT'}, {"denom": "'$DENOM_SYMBOL'", "exponent": '$DENOM_EXPONENT'}],"base": "'$MIN_DENOM_SYMBOL'", "display": "'$DENOM_SYMBOL'", "name": "'$DENOM_SYMBOL'", "symbol": "'$DENOM_SYMBOL'"}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
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
if [ $DISABLE_CLAIM -eq 0 ]; then
    echo "- Set claim records for 3 validators in [app_state > claims > claims_records]"
    echo " + Validator $VAL_1_ADDR (node 0) can claim "$(bc <<< "$VAL_1_CLAIM / (10^$DENOM_EXPONENT)")$DENOM_SYMBOL
    echo " + Validator $VAL_2_ADDR (node 1) can claim "$(bc <<< "$VAL_2_CLAIM / (10^$DENOM_EXPONENT)")$DENOM_SYMBOL
    echo " + Validator $VAL_3_ADDR (node 2) can claim "$(bc <<< "$VAL_3_CLAIM / (10^$DENOM_EXPONENT)")$DENOM_SYMBOL
    cat $GENESIS_JSON | jq '.app_state["claims"]["claims_records"]=[{"initial_claimable_amount":"'$VAL_1_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_1_ADDR'"},{"initial_claimable_amount":"'$VAL_2_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_2_ADDR'"},{"initial_claimable_amount":"'$VAL_3_CLAIM'", "actions_completed":[false, false, false, false],"address":"'$VAL_3_ADDR'"}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
fi
## Set claims decay
duration_until_decay="86400s"
duration_of_decay="2592000s"
echo "- Set duration until decay in [app_state > claims > params > duration_until_decay] to $duration_until_decay"
cat $GENESIS_JSON | jq '.app_state["claims"]["params"]["duration_until_decay"]="'$duration_until_decay'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
echo "- Set duration of decay in [app_state > claims > params > duration_of_decay] to $duration_of_decay"
cat $GENESIS_JSON | jq '.app_state["claims"]["params"]["duration_of_decay"]="'$duration_of_decay'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
if [ $DISABLE_CLAIM -eq 0 ]; then
    ## Claim module account:
    ### 0xA61808Fe40fEb8B3433778BBC2ecECCAA47c8c47 || evmos15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz
    amount_to_claim=$(bc <<< "$VAL_1_CLAIM + $VAL_2_CLAIM + $VAL_3_CLAIM")
    echo '- Claimn module account addr '$EVMOS_CLAIM_MODULE_ACCOUNT', total '$(bc <<< "$amount_to_claim / (10^$DENOM_EXPONENT)")' '$DENOM_SYMBOL
    cat $GENESIS_JSON | jq '.app_state["bank"]["balances"] += [{"address":"'$EVMOS_CLAIM_MODULE_ACCOUNT'","coins":[{"denom":"'$MIN_DENOM_SYMBOL'", "amount":"'$amount_to_claim'"}]}]' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON
fi


# Update app.toml
update_app() {
    VAL_HOME=$1
    APP_TOML="$VAL_HOME/config/app.toml"
    APP_TOML_TMP="$VAL_HOME/config/tmp_app.toml"
    echo "Updating app.toml in $VAL_HOME"
    echo '- Enable API by setting [api > enable] to "true"'
    cat $APP_TOML | tomlq '.api["enable"]=true' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
    echo '- Enable Swagger (access via http://host/swagger/) by setting [api > swagger] to "true"'
    cat $APP_TOML | tomlq '.api["swagger"]=true' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
    echo "- Bind API to 0.0.0.0:1317 by updating [api > address]"
    cat $APP_TOML | tomlq '.api["address"]="tcp://0.0.0.0:1317"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
    echo "- Bind Json-RPC to 0.0.0.0:8545 by updating [json-rpc > address]"
    cat $APP_TOML | tomlq '."json-rpc"["address"]="0.0.0.0:8545"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
    echo "- Bind gRPC to 0.0.0.0:9090 by updating [grpc > address]"
    cat $APP_TOML | tomlq '.grpc["address"]="0.0.0.0:9090"' --toml-output > $APP_TOML_TMP && mv $APP_TOML_TMP $APP_TOML
}

update_app $VAL_HOME_1
update_app $VAL_HOME_2
update_app $VAL_HOME_3

# Allocate genesis accounts
echo 'Allocating genesis accounts'
if [ "$KEYRING" = "test" ]; then
    $BINARY add-genesis-account "$VAL_1_KEY_NAME" "$VAL_1_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_1"
    $BINARY add-genesis-account "$VAL_2_KEY_NAME" "$VAL_2_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_1"
    $BINARY add-genesis-account "$VAL_3_KEY_NAME" "$VAL_3_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_1"
    # To generate create validator tx for validator 2 & 3
    $BINARY add-genesis-account "$VAL_2_KEY_NAME" "$VAL_2_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_2"
    $BINARY add-genesis-account "$VAL_3_KEY_NAME" "$VAL_3_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_3"
else
    echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY add-genesis-account "$VAL_1_KEY_NAME" "$VAL_1_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_1"
    echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY add-genesis-account "$VAL_2_KEY_NAME" "$VAL_2_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_1"
    echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY add-genesis-account "$VAL_3_KEY_NAME" "$VAL_3_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_1"
    # To generate create validator tx for validator 2 & 3
    echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY add-genesis-account "$VAL_2_KEY_NAME" "$VAL_2_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_2"
    echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY add-genesis-account "$VAL_3_KEY_NAME" "$VAL_3_BALANCE"$MIN_DENOM_SYMBOL --keyring-backend $KEYRING --home "$VAL_HOME_3"
fi

# Update total supply + claim values in genesis.json
total_supply=$(bc <<< "$VAL_1_BALANCE + $VAL_2_BALANCE + $VAL_3_BALANCE + $VAL_1_CLAIM + $VAL_2_CLAIM + $VAL_3_CLAIM")
echo 'Update original total supply = '$(bc <<< "$total_supply / (10^$DENOM_EXPONENT)")' '$DENOM_SYMBOL' into [app_state > bank > supply[0] > amount]'
cat $GENESIS_JSON | jq '.app_state["bank"]["supply"][0]["amount"]="'$total_supply'"' > $GENESIS_JSON_TMP && mv $GENESIS_JSON_TMP $GENESIS_JSON

# Sign genesis transaction
echo 'Generate genesis staking transaction '$(bc <<< "$VAL_1_STAKE / (10^$DENOM_EXPONENT)")' '$DENOM_SYMBOL' for validator '$VAL_1_KEY_NAME
if [ "$KEYRING" = "test" ]; then
    $BINARY gentx $VAL_1_KEY_NAME "$VAL_1_STAKE"$MIN_DENOM_SYMBOL \
        --commission-rate="$VAL_COMMISSION_RATE" \
        --commission-max-rate="$VAL_COMMISSION_RATE_MAX" \
        --commission-max-change-rate="$VAL_COMMISSION_CHANGE_RATE_MAX" \
        --min-self-delegation="$VAL_MIN_SELF_DELEGATION" \
        --keyring-backend $KEYRING \
        --chain-id $CHAIN_ID \
        --home $VAL_HOME_1 > /dev/null 2>&1
else
    echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY gentx $VAL_1_KEY_NAME "$VAL_1_STAKE"$MIN_DENOM_SYMBOL \
        --commission-rate="$VAL_COMMISSION_RATE" \
        --commission-max-rate="$VAL_COMMISSION_RATE_MAX" \
        --commission-max-change-rate="$VAL_COMMISSION_CHANGE_RATE_MAX" \
        --min-self-delegation="$VAL_MIN_SELF_DELEGATION" \
        --keyring-backend $KEYRING \
        --chain-id $CHAIN_ID \
        --home $VAL_HOME_1 > /dev/null 2>&1
fi
[ $? -eq 0 ] || { echo "ERR: Failed to create genesis tx for validator 1"; exit 1; }

echo 'Generate genesis staking transaction '$(bc <<< "$VAL_2_STAKE / (10^$DENOM_EXPONENT)")' '$DENOM_SYMBOL' for validator '$VAL_2_KEY_NAME
if [ "$KEYRING" = "test" ]; then
    $BINARY gentx $VAL_2_KEY_NAME "$VAL_2_STAKE"$MIN_DENOM_SYMBOL \
        --commission-rate="$VAL_COMMISSION_RATE" \
        --commission-max-rate="$VAL_COMMISSION_RATE_MAX" \
        --commission-max-change-rate="$VAL_COMMISSION_CHANGE_RATE_MAX" \
        --min-self-delegation="$VAL_MIN_SELF_DELEGATION" \
        --keyring-backend $KEYRING \
        --chain-id $CHAIN_ID \
        --home $VAL_HOME_2 > /dev/null 2>&1
else
    echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY gentx $VAL_2_KEY_NAME "$VAL_2_STAKE"$MIN_DENOM_SYMBOL \
        --commission-rate="$VAL_COMMISSION_RATE" \
        --commission-max-rate="$VAL_COMMISSION_RATE_MAX" \
        --commission-max-change-rate="$VAL_COMMISSION_CHANGE_RATE_MAX" \
        --min-self-delegation="$VAL_MIN_SELF_DELEGATION" \
        --keyring-backend $KEYRING \
        --chain-id $CHAIN_ID \
        --home $VAL_HOME_2 > /dev/null 2>&1
fi
[ $? -eq 0 ] || { echo "ERR: Failed to create genesis tx for validator 2"; exit 1; }
echo "Copy generated tx to $VAL_HOME_1/config/gentx"
cp $VAL_HOME_2/config/gentx/gentx-* $VAL_HOME_1/config/gentx/

echo 'Generate genesis staking transaction '$(bc <<< "$VAL_3_STAKE / (10^$DENOM_EXPONENT)")' '$DENOM_SYMBOL' for validator '$VAL_3_KEY_NAME
if [ "$KEYRING" = "test" ]; then
    $BINARY gentx $VAL_3_KEY_NAME "$VAL_3_STAKE"$MIN_DENOM_SYMBOL \
        --commission-rate="$VAL_COMMISSION_RATE" \
        --commission-max-rate="$VAL_COMMISSION_RATE_MAX" \
        --commission-max-change-rate="$VAL_COMMISSION_CHANGE_RATE_MAX" \
        --min-self-delegation="$VAL_MIN_SELF_DELEGATION" \
        --keyring-backend $KEYRING \
        --chain-id $CHAIN_ID \
        --home $VAL_HOME_3 > /dev/null 2>&1
else
    echo "$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD" | $BINARY gentx $VAL_3_KEY_NAME "$VAL_3_STAKE"$MIN_DENOM_SYMBOL \
        --commission-rate="$VAL_COMMISSION_RATE" \
        --commission-max-rate="$VAL_COMMISSION_RATE_MAX" \
        --commission-max-change-rate="$VAL_COMMISSION_CHANGE_RATE_MAX" \
        --min-self-delegation="$VAL_MIN_SELF_DELEGATION" \
        --keyring-backend $KEYRING \
        --chain-id $CHAIN_ID \
        --home $VAL_HOME_3 > /dev/null 2>&1
fi
[ $? -eq 0 ] || { echo "ERR: Failed to create genesis tx for validator 3"; exit 1; }
echo "Copy generated tx to $VAL_HOME_1/config/gentx"
cp $VAL_HOME_3/config/gentx/gentx-* $VAL_HOME_1/config/gentx/

# Collect genesis tx to genesis.json
echo "Collecting genesis transactions into genesis.json"
$BINARY collect-gentxs --home $VAL_HOME_1 > /dev/null 2>&1
[ $? -eq 0 ] || { echo "ERR: Failed to collect genesis transactions"; exit 1; }

# Validate genesis.json
$BINARY validate-genesis --home $VAL_HOME_1
[ $? -eq 0 ] || { echo "ERR: Failed to validate genesis"; exit 1; }


# Update config.toml
TENDERMINT_NODE_ID_1=$($BINARY tendermint show-node-id --home $VAL_HOME_1)
TENDERMINT_NODE_ID_2=$($BINARY tendermint show-node-id --home $VAL_HOME_2)
TENDERMINT_NODE_ID_3=$($BINARY tendermint show-node-id --home $VAL_HOME_3)
update_config() {
    VAL_HOME=$1
    CONFIG_TOML="$VAL_HOME/config/config.toml"
    CONFIG_TOML_TMP="$VAL_HOME/config/tmp_config.toml"
    echo "Updating config.toml in $VAL_HOME"
    ## Update seed nodes
    echo '- Add seeds to [p2p > seeds]'
    cat $CONFIG_TOML | tomlq '.p2p["seeds"]="'$TENDERMINT_NODE_ID_1'@'$CONTAINER_PREFIX'0:26656,'$TENDERMINT_NODE_ID_2'@'$CONTAINER_PREFIX'1:26656,'$TENDERMINT_NODE_ID_3'@'$CONTAINER_PREFIX'2:26656"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
    echo '- Add persistent peers to [p2p > persistent_peers]'
    cat $CONFIG_TOML | tomlq '.p2p["persistent_peers"]="'$TENDERMINT_NODE_ID_1'@'$CONTAINER_PREFIX'0:26656,'$TENDERMINT_NODE_ID_2'@'$CONTAINER_PREFIX'1:26656,'$TENDERMINT_NODE_ID_3'@'$CONTAINER_PREFIX'2:26656"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
    ## Disable create empty block
    ###echo '- Disable create empty block by setting [root > create_empty_blocks] to false'
    ###cat $CONFIG_TOML | tomlq '.["create_empty_blocks"]=false' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
    ## Expose ports
    echo "- Bind RPC to 0.0.0.0:26657 by updating [rpc > laddr]"
    cat $CONFIG_TOML | tomlq '.rpc["laddr"]="tcp://0.0.0.0:26657"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
    echo "- Bind Peer to 0.0.0.0:26656 by updating [p2p > laddr]"
    cat $CONFIG_TOML | tomlq '.p2p["laddr"]="tcp://0.0.0.0:26656"' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML
}

update_config $VAL_HOME_1
update_config $VAL_HOME_2
update_config $VAL_HOME_3

# Copy
echo 'Copy genesis.json'
echo '- Copying genesis.json from node 0 to node 1'
cp "$VAL_HOME_1/config/genesis.json" "$VAL_HOME_2/config/genesis.json"
echo '- Copying genesis.json from node 0 to node 2'
cp "$VAL_HOME_1/config/genesis.json" "$VAL_HOME_3/config/genesis.json"

# Update config.toml part 3
echo "Updating config.toml part 3"
echo '- Clean seeds of node 0'
cat $CONFIG_TOML | tomlq '.p2p["seeds"]=""' --toml-output > $CONFIG_TOML_TMP && mv $CONFIG_TOML_TMP $CONFIG_TOML

echo '### Done, you can move to next step'
