#!/bin/bash

# Pre-requisites
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/ (Hint: sudo apt install jq -y)"; exit 1; }
command -v yq > /dev/null 2>&1 || { echo >&2 "yq not installed. More info: https://github.com/kislyuk/yq/ (Hint: sudo apt install python3-pip -y && pip3 install yq)"; exit 1; }
command -v tomlq > /dev/null 2>&1 || { echo >&2 "tomlq not installed, it is expected to be delivered within yq package"; exit 1; }
command -v bc > /dev/null 2>&1 || { echo >&2 "bc command could not be found"; exit 1; }
command -v make > /dev/null 2>&1 || { echo >&2 "make command could not be found"; exit 1; }
command -v go > /dev/null 2>&1 || { echo >&2 "go was not installed. More info: https://go.dev/doc/install"; exit 1; }

# Configurations

export KEYRING="test" # change to file for cloud or production env (DANGER: keyring test will allow transfer token from validator without key)
export NOTICE_DEV_ENV="This sample scripts was developed on an Ubuntu 22.04 LTS machine"

## EVMOS (network)
export EVMOS_BINARY="evmosd"
export EVMOS_DENOM_EXPONENT=18 # no of digits
export EVMOS_GAS_DENOM_EXPONENT=9 # no of digits
export EVMOS_CLAIM_MODULE_ACCOUNT="evmos15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz"
export EVMOS_CHAIN_1_REPO="https://github.com/evmos/evmos.git"
export EVMOS_CHAIN_1_BRANCH="v5.0.0"
export EVMOS_CHAIN_1_REPO="https://github.com/evmos/evmos.git"
export EVMOS_CHAIN_2_BRANCH="v5.0.0"

## Validators
export VAL_RAW_BALANCE=50000000 # Init with 50m EVMOS in balance for each validator
export VAL_RAW_CLAIM=1000 # Each validator can claimn this amount
export VAL_KEYS_FILE_DECRYPT_PASSWORD="11111111"
export VAL_COMMISSION_RATE=0.05 # 5%
export VAL_COMMISSION_RATE_MAX=0.20 # 20%
export VAL_COMMISSION_CHANGE_RATE_MAX=0.01 # 1%
export VAL_MIN_SELF_DELEGATION=1000000
export VAL_GAS_LIMIT_CREATE_VALIDATOR=300000
### Validator 1
export VAL_1_KEY_NAME="val1"
export VAL_1_SEED="spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi"
export VAL_1_ADDR="evmos1wuqvcpuunf7r5rg7xutqddhw55grfzc75qejyq"
export VAL_1_RAW_STAKE=7000 # Validator 1 will stake 7k EVMOS
### Validator 2
export VAL_2_KEY_NAME="val2"
export VAL_2_SEED="width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle"
export VAL_2_ADDR="evmos1zxgt4pwzzsv02z24g80lc5rhtsp0prw0c5tk3d"
export VAL_2_RAW_STAKE=3000 # Validator 2 will stake 3k EVMOS
### Validator 3
export VAL_3_KEY_NAME="val3"
export VAL_3_SEED="stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father"
export VAL_3_ADDR="evmos1vcy9v4jp0sd4hysqqcuwleytxre3ms4ckzmdnz"
export VAL_3_RAW_STAKE=3000 # Validator 3 will stake 3k EVMOS

## Custom chain (design for future script update)
export DENOM_SYMBOL="evmos"
export MIN_DENOM_SYMBOL="aevmos"
export GAS_DENOM_SYMBOL="nevmos"

## Multichain config
### Chain 1
export CHAIN_1_ID="evmos_9006-1"
export CHAIN_1_COINTYPE=60
### Chain 2
export CHAIN_2_ID="evmos_9007-1"
export CHAIN_2_COINTYPE=60

## Hermes (IBC Relayer)
export HERMES_VER="v0.15.0"
export HERMES_BINARY="hermes"
export HERMES_SOURCE_DIR="Hermes-source-code" # do NOT modify
export HERMES_HOME_DIR=".hermes"
export HERMES_RESERVED_FEE=100 # will be transfered to relayer's account and reserved for relay purpose
export HERMES_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export HERMES_CFG_CHAIN_1_RPC_ADDR="127.0.0.1:26657"
export HERMES_CFG_CHAIN_1_GRPC_ADDR="127.0.0.1:9090"
export HERMES_CFG_CHAIN_1_ACCOUNT_PREFIX="evmos"
export HERMES_CFG_CHAIN_1_KEY_NAME="evmoskey"
export HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL="$MIN_DENOM_SYMBOL"
export HERMES_CFG_CHAIN_2_ID="$CHAIN_2_ID"
export HERMES_CFG_CHAIN_2_RPC_ADDR="127.0.0.1:36657"
export HERMES_CFG_CHAIN_2_GRPC_ADDR="127.0.0.1:19090"
export HERMES_CFG_CHAIN_2_ACCOUNT_PREFIX="evmos"
export HERMES_CFG_CHAIN_2_KEY_NAME="evmoskey"
export HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL="$MIN_DENOM_SYMBOL"

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
export BD_BRANCH="chains/evmos/mainnet"
export BD_SOURCE_DIR="bdjuno-source-code" # do NOT modify
export BD_BINARY="$GOPATH/bin/bdjuno"
export BD_PG_DB=bdjuno
export BD_PG_USER=bdjuno
export BD_PG_PASS=6N4QtFYMt7h972uazrWTckmMvFZWIje
export BD_HASURA_BINARY=/usr/local/bin/hasura
export BD_HASURA_PORT=8080
export BD_HASURA_SECRET=myadminsecretkey
export BD_HASURA_ACTIONBASE_PORT=3000
export BD_PG_HASURA_META_DB=hasurameta
export BD_PG_HASURA_DB=hasura
export BD_PG_HASURA_USER=hasura
export BD_PG_HASURA_PASS=PX2RNvtZ4m7fntnbRrtySB4ROG5EKk4J
export BD_CFG_PG_USR_PASS=6N4QtFYMt7h972uazrWTckmMvFZWIje # Password of default user postgres
export BD_CFG_CHAIN_1_PG_PORT=5432
export BD_CFG_CHAIN_1_ACCOUNT_PREFIX="evmos"
export BD_CFG_CHAIN_1_RPC_ADDR="127.0.0.1:26657"
export BD_CFG_CHAIN_1_GRPC_ADDR="127.0.0.1:9090"
export BD_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export BD_CFG_CHAIN_2_PG_PORT=15432
export BD_CFG_CHAIN_2_ACCOUNT_PREFIX="evmos"
export BD_CFG_CHAIN_2_RPC_ADDR="127.0.0.1:36657"
export BD_CFG_CHAIN_2_GRPC_ADDR="127.0.0.1:19090"
export BD_CFG_CHAIN_2_ID="$CHAIN_2_ID"

## Reflects by above config (edit at your own risk)
export EVMOS_CHAINNAME=$(echo $DENOM_SYMBOL | tr '[:lower:]' '[:upper:]')
export EVMOS_MONIKER=$DENOM_SYMBOL'AIO'
export HERMES_SERVICE_NAME=$HERMES_BINARY'-svc'
### Validators
#### Balance
export VAL_1_BALANCE=$(bc <<< "10^$EVMOS_DENOM_EXPONENT * $VAL_RAW_BALANCE")
export VAL_2_BALANCE=$VAL_1_BALANCE
export VAL_3_BALANCE=$VAL_1_BALANCE
#### Stake
export VAL_1_STAKE=$(bc <<< "10^$EVMOS_DENOM_EXPONENT * $VAL_1_RAW_STAKE")
export VAL_2_STAKE=$(bc <<< "10^$EVMOS_DENOM_EXPONENT * $VAL_2_RAW_STAKE")
export VAL_3_STAKE=$(bc <<< "10^$EVMOS_DENOM_EXPONENT * $VAL_3_RAW_STAKE")
#### Claim
export VAL_1_CLAIM=$(bc <<< "10^$EVMOS_DENOM_EXPONENT * $VAL_RAW_CLAIM")
export VAL_2_CLAIM=$VAL_1_CLAIM
export VAL_3_CLAIM=$VAL_1_CLAIM
### Docker
export DOCKER_IMAGE_NAME_PREFIX="$DENOM_SYMBOL.victortrusty.dev:c"

## IP addresses
export IP_EVMOS_1_INT="evmos1i.victortrusty.dev"
export IP_EVMOS_2_INT="evmos2i.victortrusty.dev"
export IP_EVMOS_3_INT="evmos3i.victortrusty.dev"
export IP_EVMOS_1_EXT="evmos1.victortrusty.dev"
export IP_EVMOS_2_EXT="evmos2.victortrusty.dev"
export IP_EVMOS_3_EXT="evmos3.victortrusty.dev"

# Others
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
command -v timeout > /dev/null 2>&1
if [ $? -eq 0 ]; then
    export SUPPORTS_TIMEOUT=1
else
    export SUPPORTS_TIMEOUT=0
fi
if [ -f "./extra_func.lic" ]; then
    export EXTRA_FUNC=1
elif [ -f "../extra_func.lic" ]; then
    export EXTRA_FUNC=1
else
    export EXTRA_FUNC=0
fi
export NETWORK_PORT_OFFSET_1=0
export NETWORK_PORT_OFFSET_2=1000
if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi