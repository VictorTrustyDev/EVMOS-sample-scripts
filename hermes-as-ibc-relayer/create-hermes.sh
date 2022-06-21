#!/bin/bash

command -v cargo > /dev/null 2>&1 || { echo >&2 "Rust & Cargo was not installed. More info: https://www.rust-lang.org/tools/install . Hint: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"; exit 1; }

source ../env.sh

[ $DISABLE_SYSTEMCTL -eq 0 ] && {
    echo "Stopping $HERMES_SERVICE_NAME service";
    sudo systemctl stop $HERMES_SERVICE_NAME;
    sudo systemctl disable $HERMES_SERVICE_NAME;
}

echo "Remove previous setup"
rm -rf "$HERMES_HOME_DIR"

echo "Init new home dir"
mkdir -p "$HERMES_HOME_DIR"

echo 'You can custom config by editing keys with prefix [HERMES_CFG_CHAIN_*] in [env.sh] file'
sleep 3s

echo "Chain ID: $HERMES_CFG_CHAIN_1_ID and $HERMES_CFG_CHAIN_2_ID"
echo "Chain 1:"
echo "- RPC: $HERMES_CFG_CHAIN_1_RPC_ADDR"
echo "- gRPC: $HERMES_CFG_CHAIN_1_GRPC_ADDR"
echo "- Account prefix: $HERMES_CFG_CHAIN_1_ACCOUNT_PREFIX"
echo "- Relayer tx broadcast account key name: $HERMES_CFG_CHAIN_1_KEY_NAME"
echo "- Gas price denom: $HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL"
echo "Chain 2:"
echo "- RPC: $HERMES_CFG_CHAIN_2_RPC_ADDR"
echo "- gRPC: $HERMES_CFG_CHAIN_2_GRPC_ADDR"
echo "- Account prefix: $HERMES_CFG_CHAIN_2_ACCOUNT_PREFIX"
echo "- Relayer tx broadcast account key name: $HERMES_CFG_CHAIN_2_KEY_NAME"
echo "- Gas price denom: $HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL"
sleep 3s

echo "Initializing file config.toml"
CONFIG_TOML=$HERMES_HOME_DIR'/config.toml'
cp "./template-config.toml" "$CONFIG_TOML"
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/chain1_id/$HERMES_CFG_CHAIN_1_ID/g" $CONFIG_TOML
    sed -i '' "s,chain1_rpc_addr,$HERMES_CFG_CHAIN_1_RPC_ADDR,g" $CONFIG_TOML
    sed -i '' "s,chain1_grpc_addr,$HERMES_CFG_CHAIN_1_GRPC_ADDR,g" $CONFIG_TOML
    sed -i '' "s/chain1_account_prefix/$HERMES_CFG_CHAIN_1_ACCOUNT_PREFIX/g" $CONFIG_TOML
    sed -i '' "s/chain1_key_name/$HERMES_CFG_CHAIN_1_KEY_NAME/g" $CONFIG_TOML
    sed -i '' "s/chain1_gas_price_denom/$HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL/g" $CONFIG_TOML
    sed -i '' "s/chain2_id/$HERMES_CFG_CHAIN_2_ID/g" $CONFIG_TOML
    sed -i '' "s,chain2_rpc_addr,$HERMES_CFG_CHAIN_2_RPC_ADDR,g" $CONFIG_TOML
    sed -i '' "s,chain2_grpc_addr,$HERMES_CFG_CHAIN_2_GRPC_ADDR,g" $CONFIG_TOML
    sed -i '' "s/chain2_account_prefix/$HERMES_CFG_CHAIN_2_ACCOUNT_PREFIX/g" $CONFIG_TOML
    sed -i '' "s/chain2_key_name/$HERMES_CFG_CHAIN_2_KEY_NAME/g" $CONFIG_TOML
    sed -i '' "s/chain2_gas_price_denom/$HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL/g" $CONFIG_TOML
else
    sed -i "s/chain1_id/$HERMES_CFG_CHAIN_1_ID/g" $CONFIG_TOML
    sed -i "s,chain1_rpc_addr,$HERMES_CFG_CHAIN_1_RPC_ADDR,g" $CONFIG_TOML
    sed -i "s,chain1_grpc_addr,$HERMES_CFG_CHAIN_1_GRPC_ADDR,g" $CONFIG_TOML
    sed -i "s/chain1_account_prefix/$HERMES_CFG_CHAIN_1_ACCOUNT_PREFIX/g" $CONFIG_TOML
    sed -i "s/chain1_key_name/$HERMES_CFG_CHAIN_1_KEY_NAME/g" $CONFIG_TOML
    sed -i "s/chain1_gas_price_denom/$HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL/g" $CONFIG_TOML
    sed -i "s/chain2_id/$HERMES_CFG_CHAIN_2_ID/g" $CONFIG_TOML
    sed -i "s,chain2_rpc_addr,$HERMES_CFG_CHAIN_2_RPC_ADDR,g" $CONFIG_TOML
    sed -i "s,chain2_grpc_addr,$HERMES_CFG_CHAIN_2_GRPC_ADDR,g" $CONFIG_TOML
    sed -i "s/chain2_account_prefix/$HERMES_CFG_CHAIN_2_ACCOUNT_PREFIX/g" $CONFIG_TOML
    sed -i "s/chain2_key_name/$HERMES_CFG_CHAIN_2_KEY_NAME/g" $CONFIG_TOML
    sed -i "s/chain2_gas_price_denom/$HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL/g" $CONFIG_TOML
fi

# Binary
export BINARY=$HERMES_SOURCE_DIR'/target/release/'$HERMES_BINARY

# Check & Install hermes binary if not exists
./_make_binary.sh
[ $? -eq 0 ] || { echo "Failed to check & build $HERMES_BINARY binary at $BINARY"; }

# Restore relayer account
echo "Importing seed"
echo " [$REL_1_SEED]"
echo " as relayer account for chain $HERMES_CFG_CHAIN_1_ID"
$BINARY -c $CONFIG_TOML keys restore --mnemonic "$REL_1_SEED" --hd-path "m/44'/$CHAIN_1_COINTYPE'/0'/0/0" $HERMES_CFG_CHAIN_1_ID
echo "Importing seed"
echo " [$REL_2_SEED]"
echo " as relayer account for chain $HERMES_CFG_CHAIN_2_ID"
$BINARY -c $CONFIG_TOML keys restore --mnemonic "$REL_2_SEED" --hd-path "m/44'/$CHAIN_2_COINTYPE'/0'/0/0" $HERMES_CFG_CHAIN_2_ID

echo "Creating client, connection and channels"
echo '- Creating client'
RES_CREATE_CLIENT_1_TO_2=$($BINARY tx raw create-client $HERMES_CFG_CHAIN_1_ID $HERMES_CFG_CHAIN_2_ID)
TENDERMINT_CLIENT_1_TO_2=$(echo $RES_CREATE_CLIENT_1_TO_2 | grep -o '07-tendermint-[0-9]*')
echo ' > Client 1 to 2: '$TENDERMINT_CLIENT_1_TO_2

RES_CREATE_CLIENT_2_TO_1=$($BINARY tx raw create-client $HERMES_CFG_CHAIN_2_ID $HERMES_CFG_CHAIN_1_ID)
TENDERMINT_CLIENT_2_TO_1=$(echo $RES_CREATE_CLIENT_2_TO_1 | grep -o '07-tendermint-[0-9]*')
echo ' > Client 2 to 1: '$TENDERMINT_CLIENT_2_TO_1

echo '- Creating connection'
RES_CREATE_CONN_1_TO_2=$($BINARY tx raw conn-init $HERMES_CFG_CHAIN_1_ID $HERMES_CFG_CHAIN_2_ID $TENDERMINT_CLIENT_1_TO_2 $TENDERMINT_CLIENT_2_TO_1)
CONN_1_TO_2=$(echo $RES_CREATE_CONN_1_TO_2 | grep -o 'connection-[0-9]*')
echo ' > Connection 1 to 2: '$CONN_1_TO_2

RES_CREATE_CONN_2_TO_1=$($BINARY tx raw conn-try $HERMES_CFG_CHAIN_2_ID $HERMES_CFG_CHAIN_1_ID $TENDERMINT_CLIENT_2_TO_1 $TENDERMINT_CLIENT_1_TO_2 -s $CONN_1_TO_2)
CONN_2_TO_1=$(echo $RES_CREATE_CONN_2_TO_1 | grep -o 'connection-[0-9]*' | head -n 1)
echo ' > Connection 2 to 1: '$CONN_2_TO_1

$BINARY tx raw conn-ack $HERMES_CFG_CHAIN_1_ID $HERMES_CFG_CHAIN_2_ID $TENDERMINT_CLIENT_1_TO_2 $TENDERMINT_CLIENT_2_TO_1 -d $CONN_1_TO_2 -s $CONN_2_TO_1
sleep 3s
$BINARY tx raw conn-confirm $HERMES_CFG_CHAIN_2_ID $HERMES_CFG_CHAIN_1_ID $TENDERMINT_CLIENT_2_TO_1 $TENDERMINT_CLIENT_1_TO_2 -d $CONN_2_TO_1 -s $CONN_1_TO_2

echo ' + Testing connection 1'
$BINARY query connection end $HERMES_CFG_CHAIN_1_ID $CONN_1_TO_2 | grep 'Open'

echo ' + Testing connection 2'
$BINARY query connection end $HERMES_CFG_CHAIN_2_ID $CONN_2_TO_1 | grep 'Open'

echo '- Creating channel'

RES_CREATE_CHAN_1_TO_2=$($BINARY tx raw chan-open-init $HERMES_CFG_CHAIN_1_ID $HERMES_CFG_CHAIN_2_ID $CONN_1_TO_2 transfer transfer -o UNORDERED)
CHAN_1_TO_2=$(echo $RES_CREATE_CHAN_1_TO_2 | grep -o 'channel-[0-9]*')

RES_CREATE_CHAN_2_TO_1=$($BINARY tx raw chan-open-try $HERMES_CFG_CHAIN_2_ID $HERMES_CFG_CHAIN_1_ID $CONN_2_TO_1 transfer transfer -s $CHAN_1_TO_2)
CHAN_2_TO_1=$(echo $RES_CREATE_CHAN_2_TO_1 | grep -o 'channel-[0-9]*' | head -n 1)

$BINARY tx raw chan-open-ack $HERMES_CFG_CHAIN_1_ID $HERMES_CFG_CHAIN_2_ID $CONN_1_TO_2 transfer transfer -d $CHAN_1_TO_2 -s $CHAN_2_TO_1
sleep 3s
$BINARY tx raw chan-open-confirm $HERMES_CFG_CHAIN_2_ID $HERMES_CFG_CHAIN_1_ID $CONN_2_TO_1 transfer transfer -d $CHAN_2_TO_1 -s $CHAN_1_TO_2

echo ' + Testing channel 1'
$BINARY query channel end $HERMES_CFG_CHAIN_1_ID transfer $CHAN_1_TO_2 | grep 'Open'

echo ' + Testing channel 2'
$BINARY query channel end $HERMES_CFG_CHAIN_2_ID transfer $CHAN_2_TO_1 | grep 'Open'

sed -i "s/NoteClient1/Client 1 to 2: $TENDERMINT_CLIENT_1_TO_2/g" $CONFIG_TOML
sed -i "s/NoteClient2/Client 2 to 1: $TENDERMINT_CLIENT_2_TO_1/g" $CONFIG_TOML
sed -i "s/NoteConnection1/Connection 1 to 2: $CONN_1_TO_2/g" $CONFIG_TOML
sed -i "s/NoteConnection2/Connection 2 to 1: $CONN_2_TO_1/g" $CONFIG_TOML
sed -i "s/NoteChannel1/Channel 1 to 2: $CHAN_1_TO_2/g" $CONFIG_TOML
sed -i "s/NoteChannel2/Channel 2 to 1: $CHAN_2_TO_1/g" $CONFIG_TOML

echo 'Information summary'
echo '- Client 1 to 2: '$TENDERMINT_CLIENT_1_TO_2
echo '- Client 2 to 1: '$TENDERMINT_CLIENT_2_TO_1
echo '- Connection 1 to 2: '$CONN_1_TO_2
echo '- Connection 2 to 1: '$CONN_2_TO_1
echo '- Channel 1 to 2: '$CHAN_1_TO_2
echo '- Channel 2 to 1: '$CHAN_2_TO_1
echo "> The above information was saved as comment lines in [$CONFIG_TOML], you can review it any time"

echo 'Final steps need to be done'
echo '- Update config file '$CONF_FILE
echo ' + Add [chains.packet_filter] for chain '$HERMES_CFG_CHAIN_1_ID' allows transfer via '$CHAN_1_TO_2
echo ' + Add [chains.packet_filter] for chain '$HERMES_CFG_CHAIN_2_ID' allows transfer via '$CHAN_2_TO_1
echo ' + Validate config'
echo ' $ '$BINARY' -c '$CONFIG_TOML' config validate'

# Re-Start service
if [ $DISABLE_SYSTEMCTL -eq 0 ]; then
    SERVICE_FILE="/etc/systemd/system/$HERMES_SERVICE_NAME.service"
	echo
    if [ -f "$SERVICE_FILE" ]; then
        echo "You are ready to restart $HERMES_SERVICE_NAME service (sudo systemctl restart $HERMES_SERVICE_NAME)"

		[ $EXTRA_FUNC -eq 1 ] && sudo systemctl start $HERMES_SERVICE_NAME
    else
        echo "You can paste the following content to $SERVICE_FILE file to create a daemon service"
        echo "sudo vi $SERVICE_FILE"
        echo

        WORKING_DIR=$(pwd)
        
        SCRIPT_CONTENT="[Unit]
Description=Hermes as IBC Relayer ($HERMES_BINARY)
ConditionPathExists=$BINARY
After=network.target
[Service]
Type=simple
User=$USER
WorkingDirectory=$WORKING_DIR
ExecStart=$BINARY -c $CONFIG_TOML --json start
Restart=always
RestartSec=2
[Install]
WantedBy=multi-user.target"
		echo -e $SCRIPT_CONTENT
        echo
        echo "sudo systemctl enable $HERMES_SERVICE_NAME"
        echo "sudo systemctl start $HERMES_SERVICE_NAME"

        [ $EXTRA_FUNC -eq 1 ] && {
            echo 'Creating service '$HERMES_SERVICE_NAME;
            echo -e $SCRIPT_CONTENT | sudo tee $SERVICE_FILE > /dev/null;
            sudo systemctl enable $HERMES_SERVICE_NAME;
			sudo systemctl start $HERMES_SERVICE_NAME;
        }
    fi
fi

echo '### Done'