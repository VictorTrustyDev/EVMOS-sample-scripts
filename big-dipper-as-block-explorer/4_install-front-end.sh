#!/bin/bash

command -v npm > /dev/null 2>&1 || { echo >&2 "ERR: npm is required"; exit 1; }

source ../env.sh

CHAIN_NO=$1

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

if [ -f "./_config.sh" ]; then
    source "./_config.sh"
else
    echo >&2 "ERR: Wrong working directory"
    echo >&2 "Scripts must be executed within [big-dipper-as-block-explorer] directory"
    exit 1
fi

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Chain 1"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Chain 2"
else
    echo >&2 'ERR: Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo >&2 'For example:'
    echo >&2 " $0 1"
    echo >&2 " or: $0 2"
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
    echo "Big Dipper 2.0 repo exists"
    echo "Checking repo url & branch name"
    CHK_RES_1="$(git --git-dir "./$BD2_SOURCE_DIR"/.git --work-tree "./$BD2_SOURCE_DIR" config --get remote.origin.url)"
    if [ $? -ne 0 ] || [ -z "$CHK_RES_1" ]; then
        echo "WARN! Unable to check remote origin url of git repo at $BD2_SOURCE_DIR"
        sleep 2s
    elif [ "$CHK_RES_1" != "$BD2_GIT_REPO" ]; then
        echo "WARN! Git repo Url does not match"
        echo "Expected: '$BD2_GIT_REPO'"
        echo "Actual: '$CHK_RES_1'"
        echo "You should check it (script will continue execution after 10s)"
        sleep 10s
    fi
    CHK_RES_2="$(git --git-dir "./$BD2_SOURCE_DIR"/.git --work-tree "./$BD2_SOURCE_DIR" rev-parse --abbrev-ref HEAD)"
    if [ $? -ne 0 ] || [ -z "$CHK_RES_2" ]; then
        echo "WARN! Unable to check branch of git repo at $BD2_SOURCE_DIR"
        sleep 2s
    elif [ "$CHK_RES_2" = "HEAD" ]; then
        echo "WARN! Can not check branch"
    elif [ "$CHK_RES_2" != "$BD2_BRANCH" ]; then
        echo "WARN! Git Branch does not match"
        echo "Expected: '$BD2_BRANCH'"
        echo "Actual: '$CHK_RES_2'"
        echo "You should check it (script will continue execution after 10s)"
        sleep 10s
    fi
else
    echo "Downloading Big Dipper 2.0 source code from branch $BD2_BRANCH"
    git clone "$BD2_GIT_REPO" --branch "$BD2_BRANCH" --single-branch "$BD2_SOURCE_DIR"

    if [ $? -ne 0 ]; then
        echo >&2 "ERR: Git clone Big Dipper 2.0 from branch $BD2_BRANCH was failed"
        exit 1
    fi
fi

# npm environment variables
NPM_ENV="$BD2_UI_DIR/.env"
echo "Setting up file $NPM_ENV"
echo -e "
\nGRAPHQL_URL=http://$BD2_PUBLIC_DOMAIN:$BD_HASURA_PORT/v1/graphql
\nGRAPHQL_WS=ws://$BD2_PUBLIC_DOMAIN:$BD_HASURA_PORT/v1/graphql
\nNODE_ENV=test
\nPORT=$BD2_PORT
\nRPC_WEBSOCKET=ws://$BD2_PUBLIC_RPC_26657/websocket
\nNEXT_PUBLIC_CHAIN_TYPE=mainnet
\nPROJECT_NAME=web-$CHAIN_NAME
\nNEXT_PUBLIC_URL=http://$BD2_PUBLIC_DOMAIN:$BD2_PORT
" > "$NPM_ENV"

# BD2 chain config
BD2_CHAIN_CONFIG_MAINNET="$BD2_UI_DIR/src/chain.json"
BD2_CHAIN_CONFIG_TMP="$BD2_UI_DIR/src/tmp_chain.json"
echo "Setting up file chain config"
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chainName="'$CHAIN_NAME'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.title="'$CHAIN_NAME' Block Explorer"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].network="'$CHAIN_ID'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].chainType="Devnet"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].genesis["height"]=1' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].prefix["consensus"]="'$DENOM_SYMBOL'valcons"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].prefix["validator"]="'$DENOM_SYMBOL'valoper"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].prefix["account"]="'$ACCOUNT_PREFIX'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].primaryTokenUnit="'$MIN_DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].votingPowerTokenUnit="'$MIN_DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].tokenUnits["'$MIN_DENOM_SYMBOL'"]["display"]="'$DENOM_SYMBOL'"' > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET
cat "$BD2_CHAIN_CONFIG_MAINNET" | jq '.chains[0].tokenUnits["'$MIN_DENOM_SYMBOL'"]["exponent"]='$DENOM_EXPONENT > $BD2_CHAIN_CONFIG_TMP && mv $BD2_CHAIN_CONFIG_TMP $BD2_CHAIN_CONFIG_MAINNET

# BD2 codegen config
BD2_CODEGEN_YML="$BD2_UI_DIR/codegen.yml"
BD2_CODEGEN_YML_TMP="$BD2_UI_DIR/tmp_codegen.yml"
echo "Setting up file $BD2_CODEGEN_YML"
echo "- Update graphql schema"
cat "$BD2_CODEGEN_YML" | yq '.generates["./src/graphql/types/general_types.ts"]["schema"]="http://'$BD2_PUBLIC_DOMAIN':'$BD_HASURA_PORT'/v1/graphql"' -Y > "$BD2_CODEGEN_YML_TMP" && mv "$BD2_CODEGEN_YML_TMP" "$BD2_CODEGEN_YML"

CUR_DIR=$(pwd)
cd "$BD2_UI_DIR"
WORKING_DIR=$(pwd)
echo "Working dir: $WORKING_DIR"
# Build
## Gen code
echo 'Fix error files'
FILE_TOKEN_PRICE='./src/graphql/general/token_price.graphql'
TMP_FILE_TOKEN_PRICE='./src/graphql/general/tmp.token_price.graphql'
sed '/id/d' "$FILE_TOKEN_PRICE" > "$TMP_FILE_TOKEN_PRICE" && mv "$TMP_FILE_TOKEN_PRICE" "$FILE_TOKEN_PRICE"
echo 'Generating code'
yarn run graphql:codegen > /dev/null 2>&1
[ $? -eq 0 ] || { echo >&2 "ERR: Failed to run graphql:codegen"; exit 1; }
echo 'Build'
yarn install
corepack enable
yarn run build
[ $? -eq 0 ] || { echo >&2 "ERR: Failed to build"; exit 1; }

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
\nExecStart=$(which yarn) run start
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

echo "Notice!!! Make sure the service file at '/etc/systemd/system/$BD2_SERVICE_NAME.service' has correct working directort and execution path (in case you changed any repo/branch)"
