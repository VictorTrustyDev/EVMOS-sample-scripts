#!/bin/bash

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
	echo "Stopping $BD_SERVICE_NAME service";
	sudo systemctl stop $BD_SERVICE_NAME > /dev/null 2>&1;
}

# Parse
GENESIS_JSON="$BD_HOME/genesis.json"
if [ ! -f "$GENESIS_JSON" ]; then
    if [ $EXTRA_FUNC -eq 1 ]; then
        cp '../evmos-on-docker/.evmosd'$CHAIN_NO'0/config/genesis.json' "$GENESIS_JSON"
        if [ ! -f "$GENESIS_JSON" ]; then
            echo "Please copy genesis.json from your chain into $BD_HOME"
            exit 1
        fi
    else
        echo "Missing genesis.json file (expect: $GENESIS_JSON)"
        echo "Please copy that file from your chain"
        exit 1
    fi
fi
echo "Parsing genesis file"
$BD_BINARY parse genesis-file --genesis-file-path "$GENESIS_JSON" --home "$BD_HOME"
[ $? -eq 0 ] || { echo "ERR: Failed to parse genesis.json!"; exit 1; }
## Check chain id
GENESIS_CHAIN_ID=$(cat "$GENESIS_JSON" | jq .chain_id | head -n 1 | tr -d '"')

if [ "$GENESIS_CHAIN_ID" != "$CHAIN_ID" ]; then
    echo "ERR: Mis-match chain id, expect [$CHAIN_ID] but found [$GENESIS_CHAIN_ID] on genesis.json"
    exit 1
fi


# Re-Start service
if [ $DISABLE_SYSTEMCTL -eq 0 ]; then
    SERVICE_FILE="/etc/systemd/system/$BD_SERVICE_NAME.service"
	echo
    if [ -f "$SERVICE_FILE" ]; then
        echo "You are ready to restart $BD_SERVICE_NAME service (sudo systemctl restart $BD_SERVICE_NAME)"

		[ $EXTRA_FUNC -eq 1 ] && sudo systemctl start $BD_SERVICE_NAME
    else
        echo "You can paste the following content to $SERVICE_FILE file to create a daemon service"
        echo "sudo vi $SERVICE_FILE"
        echo

        WORKING_DIR=$(pwd)
        
        SCRIPT_CONTENT="[Unit]
\nDescription=BDJuno parser
\nConditionPathExists=$BD_BINARY
\nAfter=network-online.target

\n[Service]
\nUser=$USER
\nExecStart=$BD_BINARY start --home $BD_HOME
\nRestart=always
\nRestartSec=3
\nLimitNOFILE=4096

\n[Install]
\nWantedBy=multi-user.target"
		echo -e $SCRIPT_CONTENT
        echo
        echo "sudo systemctl enable $BD_SERVICE_NAME"
        echo "sudo systemctl start $BD_SERVICE_NAME"

        [ $EXTRA_FUNC -eq 1 ] && {
            echo 'Creating service '$BD_SERVICE_NAME;
            echo -e $SCRIPT_CONTENT | sudo tee $SERVICE_FILE > /dev/null;
            sudo systemctl daemon-reload;
            sudo systemctl enable $BD_SERVICE_NAME;
			sudo systemctl start $BD_SERVICE_NAME;
        }
    fi
fi

echo 'Finished bdjuno installtion'
echo
echo 'Now move to install Hasura by running 3_install-hasura.sh'


