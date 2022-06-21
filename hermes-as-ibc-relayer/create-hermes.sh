#!/bin/bash

command -v cargo > /dev/null 2>&1 || { echo >&2 "Rust & Cargo was not installed. More info: https://www.rust-lang.org/tools/install . Hint: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"; exit 1; }

source ../env.sh

echo "Stopping $HERMES_SERVICE_NAME service"
sudo systemctl stop $HERMES_SERVICE_NAME

echo "Remove previous setup"
rm -rf "$HERMES_HOME_DIR"

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
