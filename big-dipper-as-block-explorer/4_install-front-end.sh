#!/bin/bash

command -v npm > /dev/null 2>&1 || { echo >&2 "npm is required"; exit 1; }

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
BD2_CHAIN_CONFIG_TMP="$BD2_SOURCE_DIR/src/configs/tmp_chain_config.json"
echo "Setting up file mainnet chain config"
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.title="'$CHAIN_NAME' Block Explorer"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.network="'$CHAIN_ID'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.prefix["consensus"]="'$DENOM_SYMBOL'valcons"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.prefix["validator"]="'$DENOM_SYMBOL'valoper"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.prefix["account"]="'$ACCOUNT_PREFIX'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.primaryTokenUnit="'$MIN_DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.votingPowerTokenUnit="'$MIN_DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.tokenUnits["'$MIN_DENOM_SYMBOL'"]["display"]="'$DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.tokenUnits["'$MIN_DENOM_SYMBOL'"]["exponent"]='$DENOM_EXPONENT > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
echo "Setting up file testnet chain config"
cp "$BD2_CHAIN_CONFIG_MAINNET" "$BD2_CHAIN_CONFIG_TESTNET"

# BD2 codegen config
BD2_CODEGEN_YML="$BD2_SOURCE_DIR/codegen.yml"
BD2_CODEGEN_YML_TMP="$BD2_SOURCE_DIR/tmp_codegen.yml"
echo "Setting up file $BD2_CODEGEN_YML"
cat "$BD2_CODEGEN_YML" | yq '.generates["./src/graphql/types/general_types.tsx"]["schema"]="http://'$BD2_PUBLIC_DOMAIN':'$BD_HASURA_PORT'/v1/graphql"' -Y > "$BD2_CODEGEN_YML_TMP" && mv "$BD2_CODEGEN_YML_TMP" "$BD2_CODEGEN_YML"

CUR_DIR=$(pwd)
cd "$BD2_SOURCE_DIR"
WORKING_DIR=$(pwd)
# Build
## Install graphql-codegen 
npm i -D @graphql-codegen/cli > /dev/null 2>&1
[ $? -eq 0 ] || { echo "Failed to install @graphql-codegen/cli"; exit 1; }
## Gen code
echo 'Generating code'
npm run graphql:codegen
[ $? -eq 0 ] || { echo "Failed to run graphql:codegen"; exit 1; }
#echo 'Build'
#npm run build
#[ $? -eq 0 ] || { echo "Failed to build"; exit 1; }

cd "$CUR_DIR"

# Re-Start service
if [ $DISABLE_SYSTEMCTL -eq 0 ]; then
    SERVICE_FILE="/etc/systemd/system/$BD2_SERVICE_NAME.service"
	echo
    if [ -f "$SERVICE_FILE" ]; then
        echo "You are ready to restart $BD2_SERVICE_NAME service (sudo systemctl restart $BD2_SERVICE_NAME)"

		[ $EXTRA_FUNC -eq 1 ] && sudo systemctl start $BD2_SERVICE_NAME
    else
        echo "You can paste the following content to $SERVICE_FILE file to create a daemon service"
        echo "sudo vi $SERVICE_FILE"
        echo

        SCRIPT_CONTENT="[Unit]
\nDescription=Big Dipper 2.0 for $DENOM_SYMBOL chain (network $CHAIN_NO)
\nAfter=network-online.target

\n[Service]
\nUser=$USER
\nWorkingDirectory=$WORKING_DIR
\nExecStart=$(which npm) run dev
\nRestart=always
\nRestartSec=3
\nLimitNOFILE=4096

\n[Install]
\nWantedBy=multi-user.target"
		echo -e $SCRIPT_CONTENT
        echo
        echo "sudo systemctl enable $BD2_SERVICE_NAME"
        echo "sudo systemctl start $BD2_SERVICE_NAME"

        [ $EXTRA_FUNC -eq 1 ] && {
            echo 'Creating service '$BD2_SERVICE_NAME;
            echo -e $SCRIPT_CONTENT | sudo tee $SERVICE_FILE > /dev/null;
            sudo systemctl daemon-reload;
            sudo systemctl enable $BD2_SERVICE_NAME;
			sudo systemctl start $BD2_SERVICE_NAME;
        }
    fi
else
    echo "OK, you can run it now"
    echo "Hint: npm run dev"
fi