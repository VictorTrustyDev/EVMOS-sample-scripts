#!/bin/bash

#command -v npm > /dev/null 2>&1 || { echo >&2 "npm is required"; exit 1; }

source ../env.sh

CHAIN_NO=$1

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

if [ -f "./_config.sh" ]; then
    source "./_config.sh"
else
    echo "ERR: Wrong working directory"
    echo "ERR: Scripts must be executed within [big-dipper-as-block-explorer] directory"
    exit 1
fi

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Network 1"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Network 2"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

# Stop service if exists
[ $DISABLE_SYSTEMCTL -eq 0 ] && {
	echo "Stopping $BD2_SERVICE_NAME service"; 
	sudo systemctl stop $BD2_SERVICE_NAME > /dev/null 2>&1;
	sudo systemctl disable $BD2_SERVICE_NAME > /dev/null 2>&1;
}

# Check Big Dipper 2.0 source
if [ -d "$BD2_SOURCE_DIR" ]; then
    echo "Big Dipper 2.0 repo was downloaded"
else
    echo "Downloading Big Dipper 2.0 source code from branch $BD2_BRANCH"
    git clone "https://github.com/forbole/big-dipper-2.0-cosmos.git" --branch "$BD2_BRANCH" --single-branch "$BD2_SOURCE_DIR"

    if [ $? -ne 0 ]; then
        echo "Git clone Big Dipper 2.0 from branch $BD2_BRANCH was failed"
        exit 1
    fi
fi

# npm environment variables
NPM_ENV="$BD2_SOURCE_DIR/.env"
echo "Setting up file $NPM_ENV"
echo -e "
NEXT_PUBLIC_GRAPHQL_URL=http://$BD2_PUBLIC_DOMAIN:$BD_HASURA_PORT/v1/graphql
\nNEXT_PUBLIC_GRAPHQL_WS=ws://$BD2_PUBLIC_DOMAIN:$BD_HASURA_PORT/v1/graphql
\nNODE_ENV=test
\nPORT=$BD2_PORT
\nNEXT_PUBLIC_URL=http://$BD2_PUBLIC_DOMAIN:$BD2_PORT
\nNEXT_PUBLIC_RPC_WEBSOCKET=ws://$BD2_PUBLIC_RPC_26657/websocket
\nNEXT_PUBLIC_CHAIN_TYPE=mainnet
" > "$NPM_ENV"

# BD2 chain config
BD2_CHAIN_CONFIG_MAINNET="$BD2_SOURCE_DIR/src/configs/chain_config.mainnet.json"
BD2_CHAIN_CONFIG_TESTNET="$BD2_SOURCE_DIR/src/configs/chain_config.testnet.json"
BD2_CHAIN_CONFIG_TMP="$BD2_SOURCE_DIR/src/configs/chain_config.tmp.json"
echo "Setting up file mainnet chain config"
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.title="'$DENOM_SYMBOL' Block Explorer"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.network="'$CHAIN_ID'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.prefix["consensus"]="'$DENOM_SYMBOL'valcons"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.prefix["validator"]="'$DENOM_SYMBOL'valoper"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.prefix["account"]="'$ACCOUNT_PREFIX'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.primaryTokenUnit="'$MIN_DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.votingPowerTokenUnit="'$MIN_DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.tokenUnits["'$MIN_DENOM_SYMBOL'"]["display"]="'$DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat $BD2_CHAIN_CONFIG_MAINNET | jq '.tokenUnits["'$MIN_DENOM_SYMBOL'"]["exponent"]="'$DENOM_EXPONENT'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
echo "Setting up file testnet chain config"
cp "$BD2_CHAIN_CONFIG_MAINNET" "$BD2_CHAIN_CONFIG_TESTNET"