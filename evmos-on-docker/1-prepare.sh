#!/bin/bash

command -v docker > /dev/null 2>&1 || { echo >&2 "docker is required"; exit 1; }
command -v 'docker-compose' > /dev/null 2>&1 || { echo >&2 "docker-compose is required"; exit 1; }

source ../env.sh

CHAIN_NO=$1

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Going to setup an EVMOS chain with id $CHAIN_1_ID"
    export CHAIN_ID="$CHAIN_1_ID"
    export IP_EVMOS_EXT="$IP_EVMOS_1_EXT"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Going to setup an EVMOS chain with id $CHAIN_2_ID"
    export CHAIN_ID="$CHAIN_2_ID"
    export IP_EVMOS_EXT="$IP_EVMOS_2_EXT"
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

VAL_HOME_PREFIX='.evmosdn'
VAL_HOME_1=$VAL_HOME_PREFIX'0'
VAL_HOME_2=$VAL_HOME_PREFIX'1'
VAL_HOME_3=$VAL_HOME_PREFIX'2'
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
MONIKER=$EVMOS_MONIKER'-'$VAL_1_KEY_NAME
$BINARY init $MONIKER --chain-id $CHAIN_ID --home $VAL_HOME_1 > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to init chain on node 0"; exit 1; }
MONIKER=$EVMOS_MONIKER'-'$VAL_2_KEY_NAME
$BINARY init $MONIKER --chain-id $CHAIN_ID --home $VAL_HOME_2 > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to init pseudo chain for node 1"; exit 1; }
MONIKER=$EVMOS_MONIKER'-'$VAL_3_KEY_NAME
$BINARY init $MONIKER --chain-id $CHAIN_ID --home $VAL_HOME_3 > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to init pseudo chain for node 2"; exit 1; }

# Import validator keys
echo 'Import validator keys'
echo "- Copying validator keys from ../keys/keyring to <node 0_home>/keyring-$KEYRING"
cp -r ../keys/keyring/ "$VAL_HOME_1/keyring-$KEYRING"
## Verify
echo '- Verifing keys'
[ "$VAL_1_ADDR" == $($BINARY keys show $VAL_1_KEY_NAME --keyring-backend $KEYRING --home $VAL_HOME_1 --address) ] || { echo "Expect validator name $VAL_1_KEY_NAME has address $VAL_1_ADDR"; exit 1; }
echo " + OK: $VAL_1_KEY_NAME addr $VAL_1_ADDR seed '$VAL_1_SEED'"
[ "$VAL_2_ADDR" == $($BINARY keys show $VAL_2_KEY_NAME --keyring-backend $KEYRING --home $VAL_HOME_1 --address) ] || { echo "Expect validator name $VAL_2_KEY_NAME has address $VAL_2_ADDR"; exit 1; }
echo " + OK: $VAL_2_KEY_NAME addr $VAL_2_ADDR seed '$VAL_2_SEED'"
[ "$VAL_3_ADDR" == $($BINARY keys show $VAL_3_KEY_NAME --keyring-backend $KEYRING --home $VAL_HOME_1 --address) ] || { echo "Expect validator name $VAL_3_KEY_NAME has address $VAL_3_ADDR"; exit 1; }
echo " + OK: $VAL_3_KEY_NAME addr $VAL_3_ADDR seed '$VAL_3_SEED'"
echo "- Copying validator keys from ../keys/keyring to <node 1_home>/keyring-$KEYRING"
cp -r ../keys/keyring/ "$VAL_HOME_2/keyring-$KEYRING"
echo "- Copying validator keys from ../keys/keyring to <node 2_home>/keyring-$KEYRING"
cp -r ../keys/keyring/ "$VAL_HOME_3/keyring-$KEYRING"


# Update genesis.json
GENESIS_JSON="$VAL_HOME_1/config/genesis.json"
GENESIS_JSON_TMP="$VAL_HOME_1/config/tmp_genesis.json"
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
## Copy
echo '- Copying genesis.json from node 0 to node 1'
cp "$VAL_HOME_1/config/genesis.json" "$VAL_HOME_2/config/genesis.json"
echo '- Copying genesis.json from node 0 to node 2'
cp "$VAL_HOME_1/config/genesis.json" "$VAL_HOME_3/config/genesis.json"