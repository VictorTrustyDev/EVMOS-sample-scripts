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
