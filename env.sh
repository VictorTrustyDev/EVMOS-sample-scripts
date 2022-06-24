#!/bin/bash

# Pre-requisites
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/ (Hint: sudo apt install jq -y)"; exit 1; }
command -v yq > /dev/null 2>&1 || { echo >&2 "yq not installed. More info: https://github.com/kislyuk/yq/ (Hint: sudo apt install python3-pip -y && pip3 install yq)"; exit 1; }
command -v tomlq > /dev/null 2>&1 || { echo >&2 "tomlq not installed, it is expected to be delivered within yq package"; exit 1; }
command -v bc > /dev/null 2>&1 || { echo >&2 "bc command could not be found"; exit 1; }
command -v make > /dev/null 2>&1 || { echo >&2 "make command could not be found"; exit 1; }
command -v go > /dev/null 2>&1 || { echo >&2 "go was not installed. More info: https://go.dev/doc/install"; exit 1; }

# Configurations
## Keyring
### Valid values are 'file' or 'test'
### Must be lowercase
### change to file for cloud or production env (DANGER: keyring test will allow transfer token from validator without key)
export KEYRING="test" # change to file for cloud or production env (DANGER: keyring test will allow transfer token from validator without key)
##
export NOTICE_DEV_ENV="This sample scripts was developed on an Ubuntu 22.04 LTS machine"

## Network
export EVMOS_MONIKER='evmosAIO'
### Chain 1
export CHAIN_1_ID="evmos_9006-1"
export CHAIN_1_COINTYPE=60
export CHAIN_1_VALIDATOR_IMPORT_TYPE="private_key" # valid values are ('private_key' or 'pk') and ('seed' or 'seed_phrase' or 'sp')
export CHAIN_1_ACCOUNT_PREFIX="evmos"
### Chain 2
export CHAIN_2_ID="evmos_9007-1"
export CHAIN_2_COINTYPE=60
export CHAIN_2_VALIDATOR_IMPORT_TYPE="private_key" # valid values are ('private_key' or 'pk') and ('seed' or 'seed_phrase' or 'sp')
export CHAIN_2_ACCOUNT_PREFIX="evmos"
# For EVMOS, it must be 'private_key', for other cosmos chains, it must be 'seed_phrase'
export EVMOS_CHAIN_1_REPO="https://github.com/evmos/evmos.git"
export EVMOS_CHAIN_1_BRANCH="v5.0.0"
export EVMOS_CHAIN_1_DAEMON="evmosd"
export EVMOS_CHAIN_1_DENOM_SYMBOL="evmos"
export EVMOS_CHAIN_1_MIN_DENOM_SYMBOL="aevmos"
export EVMOS_CHAIN_1_GAS_DENOM_SYMBOL="nevmos"
export EVMOS_CHAIN_1_DENOM_EXPONENT=18 # no of digits
export EVMOS_CHAIN_1_GAS_DENOM_EXPONENT=9 # no of digits
export EVMOS_CHAIN_1_CLAIM_MODULE_ACCOUNT="evmos15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz"
export EVMOS_CHAIN_1_PORT_RPC=26657
export EVMOS_CHAIN_1_PORT_GRPC=9090
export EVMOS_CHAIN_1_PORT_JSON_RPC=8545
export EVMOS_CHAIN_1_PORT_REST_API=1317
export EVMOS_CHAIN_1_PORT_P2P=26656
# For EVMOS, it must be 'private_key', for other cosmos chains, it must be 'seed_phrase'
export EVMOS_CHAIN_2_REPO="https://github.com/evmos/evmos.git"
export EVMOS_CHAIN_2_BRANCH="v5.0.0"
export EVMOS_CHAIN_2_DAEMON="evmosd"
export EVMOS_CHAIN_2_DENOM_SYMBOL="evmos"
export EVMOS_CHAIN_2_MIN_DENOM_SYMBOL="aevmos"
export EVMOS_CHAIN_2_GAS_DENOM_SYMBOL="nevmos"
export EVMOS_CHAIN_2_DENOM_EXPONENT=18 # no of digits
export EVMOS_CHAIN_2_GAS_DENOM_EXPONENT=9 # no of digits
export EVMOS_CHAIN_2_CLAIM_MODULE_ACCOUNT="evmos15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz"
export EVMOS_CHAIN_2_PORT_RPC=36657
export EVMOS_CHAIN_2_PORT_GRPC=19090
export EVMOS_CHAIN_2_PORT_JSON_RPC=18545
export EVMOS_CHAIN_2_PORT_REST_API=11317
export EVMOS_CHAIN_2_PORT_P2P=36656

## Validators
export VAL_KEYRING_FILE_ENCRYPTION_PASSWORD="11111111"
export VAL_COMMISSION_RATE=0.05 # 5%
export VAL_COMMISSION_RATE_MAX=0.20 # 20%
export VAL_COMMISSION_CHANGE_RATE_MAX=0.01 # 1%
export VAL_MIN_SELF_DELEGATION=1000000
export VAL_GAS_LIMIT_CREATE_VALIDATOR=300000
### Validator 1
export VAL_1_KEY_NAME="val1"
export VAL_1_RAW_BALANCE=50000000 # Validator 1 init with this amount of coint in balance
export VAL_1_RAW_STAKE=7000 # Validator 1 will stake this amount
export VAL_1_RAW_CLAIM=1000 # Validator 1 can claim this amount
#### Chain 1
export VAL_1_CHAIN_1_SEED="spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi"
export VAL_1_CHAIN_1_PRIVATE_KEY="FC3F58B007A017166DE5A340C7A2641EB37CF37081D6F9013636CEBFBAF7B1FE"
#### Chain 2
export VAL_1_CHAIN_2_SEED="spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi"
export VAL_1_CHAIN_2_PRIVATE_KEY="FC3F58B007A017166DE5A340C7A2641EB37CF37081D6F9013636CEBFBAF7B1FE"
### Validator 2
export VAL_2_KEY_NAME="val2"
export VAL_2_RAW_BALANCE=50000000 # Validator 2 init with this amount of coint in balance
export VAL_2_RAW_STAKE=3000 # Validator 2 will stake this amount
export VAL_2_RAW_CLAIM=1000 # Validator 2 can claim this amount
#### Chain 1
export VAL_2_CHAIN_1_SEED="width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle"
export VAL_2_CHAIN_1_PRIVATE_KEY="0172DC491B5ACD04DD378D3FD8FD9F41A0D701E070941474FADECD72E1E085B9"
#### Chain 2
export VAL_2_CHAIN_2_SEED="width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle"
export VAL_2_CHAIN_2_PRIVATE_KEY="0172DC491B5ACD04DD378D3FD8FD9F41A0D701E070941474FADECD72E1E085B9"
### Validator 3
export VAL_3_KEY_NAME="val3"
export VAL_3_RAW_BALANCE=50000000 # Validator 3 init with this amount of coint in balance
export VAL_3_RAW_STAKE=3000 # Validator 3 will stake this amount
export VAL_3_RAW_CLAIM=1000 # Validator 3 can claim this amount
#### Chain 1
export VAL_3_CHAIN_1_SEED="stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father"
export VAL_3_CHAIN_1_PRIVATE_KEY="E0D83C6054597638469CC91A46F14B7F62705297912524059629E4674302928F"
#### Chain 2
export VAL_3_CHAIN_2_SEED="stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father"
export VAL_3_CHAIN_2_PRIVATE_KEY="E0D83C6054597638469CC91A46F14B7F62705297912524059629E4674302928F"

## Hermes (IBC Relayer)
export HERMES_VER="v0.15.0"
export HERMES_BINARY="hermes"
export HERMES_SOURCE_DIR="Hermes-source-code" # do NOT modify
export HERMES_HOME_DIR=".hermes"
export HERMES_RESERVED_FEE=100 # will be transfered to relayer's account and reserved for relay purpose
### Chain 1
export HERMES_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export HERMES_CFG_CHAIN_1_RPC_ADDR="127.0.0.1:$EVMOS_CHAIN_1_PORT_RPC"
export HERMES_CFG_CHAIN_1_GRPC_ADDR="127.0.0.1:$EVMOS_CHAIN_1_PORT_GRPC"
export HERMES_CFG_CHAIN_1_ACCOUNT_PREFIX="$CHAIN_1_ACCOUNT_PREFIX"
export HERMES_CFG_CHAIN_1_KEY_NAME="evmoskey"
export HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL="$EVMOS_CHAIN_1_MIN_DENOM_SYMBOL"
export HERMES_CFG_CHAIN_1_DENOM_EXPONENT=$EVMOS_CHAIN_1_DENOM_EXPONENT # no of digits
### Chain 2
export HERMES_CFG_CHAIN_2_ID="$CHAIN_2_ID"
export HERMES_CFG_CHAIN_2_RPC_ADDR="127.0.0.1:$EVMOS_CHAIN_2_PORT_RPC"
export HERMES_CFG_CHAIN_2_GRPC_ADDR="127.0.0.1:$EVMOS_CHAIN_2_PORT_GRPC"
export HERMES_CFG_CHAIN_2_ACCOUNT_PREFIX="$CHAIN_2_ACCOUNT_PREFIX"
export HERMES_CFG_CHAIN_2_KEY_NAME="evmoskey"
export HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL="$EVMOS_CHAIN_2_MIN_DENOM_SYMBOL"
export HERMES_CFG_CHAIN_2_DENOM_EXPONENT=$EVMOS_CHAIN_2_DENOM_EXPONENT # no of digits

## Relayer account
export REL_KEY_NAME="default"
### Chain 1
export REL_1_SEED="raw course slim hockey salt crawl sick safe december during armed fragile"
export REL_1_ADDR="evmos1metw56lk3k4vhkh0vzxlr8p4mzpjvttmagvekp"
### Chain 2
#export REL_2_SEED="above name soft reunion change cabin rack outside wedding orange dice impact"
#export REL_2_ADDR="evmos157g0zpv77su6awh04wec5s2jdyrk62jy40ck58"
export REL_2_SEED="raw course slim hockey salt crawl sick safe december during armed fragile"
export REL_2_ADDR="evmos1metw56lk3k4vhkh0vzxlr8p4mzpjvttmagvekp"

## Big Dipper (bdjuno)
export BD_BINARY_ORIGIN="$GOPATH/bin/bdjuno"
export BD_PG_DB=bdjuno
export BD_PG_USER=bdjuno
export BD_PG_PASS=6N4QtFYMt7h972uazrWTckmMvFZWIje
export BD_HASURA_BINARY=/usr/local/bin/hasura
export BD_HASURA_SECRET=myadminsecretkey
export BD_PG_HASURA_META_DB=hasurameta
export BD_PG_HASURA_DB=hasura
export BD_PG_HASURA_USER=hasura
export BD_PG_HASURA_PASS=PX2RNvtZ4m7fntnbRrtySB4ROG5EKk4J
export BD_CFG_PG_USR_PASS=6N4QtFYMt7h972uazrWTckmMvFZWIje # Password of default user postgres
### Chain 1
export BD_CFG_CHAIN_1_BRANCH="chains/evmos/mainnet"
export BD_CFG_CHAIN_1_PG_PORT=5432
export BD_CFG_CHAIN_1_ACCOUNT_PREFIX="$CHAIN_1_ACCOUNT_PREFIX"
export BD_CFG_CHAIN_1_RPC_ADDR="127.0.0.1:$EVMOS_CHAIN_1_PORT_RPC"
export BD_CFG_CHAIN_1_GRPC_ADDR="127.0.0.1:$EVMOS_CHAIN_1_PORT_GRPC"
export BD_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export BD_CFG_CHAIN_1_HASURA_PORT=8080
export BD_CFG_CHAIN_1_HASURA_ACTIONBASE_PORT=3000
export BD_CFG_CHAIN_1_DENOM_SYMBOL="$EVMOS_CHAIN_1_DENOM_SYMBOL" # evmos
export BD_CFG_CHAIN_1_MIN_DENOM_SYMBOL="$EVMOS_CHAIN_1_MIN_DENOM_SYMBOL" # aevmos
export BD_CFG_CHAIN_1_DENOM_EXPONENT=$EVMOS_CHAIN_1_DENOM_EXPONENT # no of digits (18)
### Chain 2
export BD_CFG_CHAIN_2_BRANCH="chains/evmos/mainnet"
export BD_CFG_CHAIN_2_PG_PORT=15432
export BD_CFG_CHAIN_2_ACCOUNT_PREFIX="$CHAIN_2_ACCOUNT_PREFIX"
export BD_CFG_CHAIN_2_RPC_ADDR="127.0.0.1:$EVMOS_CHAIN_2_PORT_RPC"
export BD_CFG_CHAIN_2_GRPC_ADDR="127.0.0.1:$EVMOS_CHAIN_2_PORT_GRPC"
export BD_CFG_CHAIN_2_ID="$CHAIN_2_ID"
export BD_CFG_CHAIN_2_HASURA_PORT=8082
export BD_CFG_CHAIN_2_HASURA_ACTIONBASE_PORT=3002
export BD_CFG_CHAIN_2_DENOM_SYMBOL="$EVMOS_CHAIN_2_DENOM_SYMBOL" # evmos
export BD_CFG_CHAIN_2_MIN_DENOM_SYMBOL="$EVMOS_CHAIN_2_MIN_DENOM_SYMBOL" # aevmos
export BD_CFG_CHAIN_2_DENOM_EXPONENT=$EVMOS_CHAIN_2_DENOM_EXPONENT # no of digits (18)
### Big Dipper 2.0 for Cosmos based chains
export BD2_SOURCE_DIR_PREFIX="bd2-source-code" # do NOT modify
### Chain 1
export BD2_CHAIN_1_BRANCH="chains/evmos"
export BD2_CFG_CHAIN_1_PORT=3800
export BD2_CFG_CHAIN_1_PUBLIC_DOMAIN="127.0.0.1"
export BD2_CFG_CHAIN_1_PUBLIC_RPC_26657="127.0.0.1:26657"
### Chain 2
export BD2_CHAIN_2_BRANCH="chains/evmos"
export BD2_CFG_CHAIN_2_PORT=3802
export BD2_CFG_CHAIN_2_PUBLIC_DOMAIN="127.0.0.1"
export BD2_CFG_CHAIN_2_PUBLIC_RPC_26657="127.0.0.1:36657"

## Reflects by above config (edit at your own risk)
export HERMES_SERVICE_NAME=$HERMES_BINARY'-svc'
### Docker
export DOCKER_IMAGE_NAME_PREFIX="evmos.victortrusty.dev:c"

# Others # Just skip this part, don't read, no more custom-able here
echo $NOTICE_DEV_ENV
if [ -z "$GOPATH" ]; then
    echo "Missing GOPATH environment variable, should be '$HOME/go'"
    exit 1
fi
command -v systemctl > /dev/null 2>&1
if [ $? -eq 0 ]; then
    export DISABLE_SYSTEMCTL=0
else
    export DISABLE_SYSTEMCTL=1
fi
if [ "$FORCE_EXTRA_FUNC" = "1" ]; then
    export EXTRA_FUNC=1
elif [ -f "./extra_func.lic" ]; then
    export EXTRA_FUNC=1
elif [ -f "../extra_func.lic" ]; then
    export EXTRA_FUNC=1
else
    export EXTRA_FUNC=0
fi
if [ -f "../override-env.sh" ]; then
    source "../override-env.sh"
fi