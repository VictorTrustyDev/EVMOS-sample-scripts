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
export KEYRING="file" # must be 'file' for cloud or production env (DANGER: keyring test will allow transfer token from validator without key)
##
export NOTICE_DEV_ENV="This sample scripts was developed on an Ubuntu 22.04 LTS machine"

## Network
export MONIKER='moniker'
### Chain 1
export CHAIN_1_TYPE="evmos" # valid values are 'evmos' or 'cosmos' only, must be 'evmos' for evmos chain, otherwise 'cosmos' for other chains
export CHAIN_1_ID="evmos_9006-1"
export CHAIN_1_COINTYPE=60 # 60 for EVMOS, 118 for Cosmos
export CHAIN_1_ACCOUNT_PREFIX="evmos"
export CHAIN_1_GIT_REPO="https://github.com/evmos/evmos.git"
export CHAIN_1_GIT_REPO_BRANCH="v5.0.0" # must belong to repo $CHAIN_1_GIT_REPO
export CHAIN_1_DAEMON_BINARY_NAME="evmosd"
export CHAIN_1_DENOM_SYMBOL="evmos"
export CHAIN_1_MIN_DENOM_SYMBOL="aevmos"
export CHAIN_1_GAS_DENOM_SYMBOL="nevmos"
export CHAIN_1_DENOM_EXPONENT=18 # no of digits (18 for evmos, 6 for cosmos atom)
export CHAIN_1_GAS_DENOM_EXPONENT=9 # no of digits (9 for evmos, 3 for cosmos atom)
export CHAIN_1_EXPOSE_RPC_TO_PORT=26657
export CHAIN_1_EXPOSE_GRPC_TO_PORT=9090
export CHAIN_1_EXPOSE_JSON_RPC_TO_PORT=8545
export CHAIN_1_EXPOSE_REST_API_TO_PORT=1317
export CHAIN_1_EXPOSE_P2P_TO_PORT=26656
### Chain 2
export CHAIN_2_TYPE="evmos" # valid values are 'evmos' or 'cosmos' only, must be 'evmos' for evmos chain, otherwise 'cosmos' for other chains
export CHAIN_2_ID="evmos_9007-1"
export CHAIN_2_COINTYPE=60 # 60 for EVMOS, 118 for Cosmos
export CHAIN_2_ACCOUNT_PREFIX="evmos"
export CHAIN_2_GIT_REPO="https://github.com/evmos/evmos.git"
export CHAIN_2_GIT_REPO_BRANCH="v5.0.0" # must belong to repo $CHAIN_2_GIT_REPO
export CHAIN_2_DAEMON_BINARY_NAME="evmosd"
export CHAIN_2_DENOM_SYMBOL="evmos"
export CHAIN_2_MIN_DENOM_SYMBOL="aevmos"
export CHAIN_2_GAS_DENOM_SYMBOL="nevmos"
export CHAIN_2_DENOM_EXPONENT=18 # no of digits (18 for evmos, 6 for cosmos atom)
export CHAIN_2_GAS_DENOM_EXPONENT=9 # no of digits (9 for evmos, 3 for cosmos atom)
export CHAIN_2_EXPOSE_RPC_TO_PORT=36657
export CHAIN_2_EXPOSE_GRPC_TO_PORT=19090
export CHAIN_2_EXPOSE_JSON_RPC_TO_PORT=18545
export CHAIN_2_EXPOSE_REST_API_TO_PORT=11317
export CHAIN_2_EXPOSE_P2P_TO_PORT=36656
#### (EVMOS specific)
### Chain 1
export EVMOS_CHAIN_1_CLAIM_MODULE_ACCOUNT="evmos15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz"
### Chain 2
export EVMOS_CHAIN_2_CLAIM_MODULE_ACCOUNT="evmos15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz"

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
export VAL_1_RAW_CLAIM=1000 # Validator 1 can claim this amount, evmos only
#### Chain 1
export VAL_1_CHAIN_1_SEED="spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi"
#### Chain 2
export VAL_1_CHAIN_2_SEED="spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi"
### Validator 2
export VAL_2_KEY_NAME="val2"
export VAL_2_RAW_BALANCE=50000000 # Validator 2 init with this amount of coint in balance
export VAL_2_RAW_STAKE=3000 # Validator 2 will stake this amount
export VAL_2_RAW_CLAIM=1000 # Validator 2 can claim this amount, evmos only
#### Chain 1
export VAL_2_CHAIN_1_SEED="width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle"
#### Chain 2
export VAL_2_CHAIN_2_SEED="width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle"
### Validator 3
export VAL_3_KEY_NAME="val3"
export VAL_3_RAW_BALANCE=50000000 # Validator 3 init with this amount of coint in balance
export VAL_3_RAW_STAKE=3000 # Validator 3 will stake this amount
export VAL_3_RAW_CLAIM=1000 # Validator 3 can claim this amount, evmos only
#### Chain 1
export VAL_3_CHAIN_1_SEED="stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father"
#### Chain 2
export VAL_3_CHAIN_2_SEED="stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father"

## Hermes (IBC Relayer)
export HERMES_GIT_REPO="https://github.com/informalsystems/ibc-rs.git"
export HERMES_GIT_REPO_BRANCH="v0.15.0" # Must belong to repo $HERMES_GIT_REPO
export HERMES_BINARY="hermes"
export HERMES_SOURCE_DIR_PREFIX="source-code" # do NOT modify
export HERMES_HOME_DIR=".hermes"
export HERMES_RESERVED_FEE=100 # will be transfered to relayer's account and reserved for relay purpose
### Chain 1
export HERMES_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export HERMES_CFG_CHAIN_1_RPC_ADDR="127.0.0.1:$CHAIN_1_EXPOSE_RPC_TO_PORT"
export HERMES_CFG_CHAIN_1_GRPC_ADDR="127.0.0.1:$CHAIN_1_EXPOSE_GRPC_TO_PORT"
export HERMES_CFG_CHAIN_1_ACCOUNT_PREFIX="$CHAIN_1_ACCOUNT_PREFIX"
export HERMES_CFG_CHAIN_1_KEY_NAME="evmoskey"
export HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL="$CHAIN_1_MIN_DENOM_SYMBOL"
export HERMES_CFG_CHAIN_1_DENOM_EXPONENT=$CHAIN_1_DENOM_EXPONENT # no of digits (18 for evmos, 6 for cosmos atom)
### Chain 2
export HERMES_CFG_CHAIN_2_ID="$CHAIN_2_ID"
export HERMES_CFG_CHAIN_2_RPC_ADDR="127.0.0.1:$CHAIN_2_EXPOSE_RPC_TO_PORT"
export HERMES_CFG_CHAIN_2_GRPC_ADDR="127.0.0.1:$CHAIN_2_EXPOSE_GRPC_TO_PORT"
export HERMES_CFG_CHAIN_2_ACCOUNT_PREFIX="$CHAIN_2_ACCOUNT_PREFIX"
export HERMES_CFG_CHAIN_2_KEY_NAME="evmoskey"
export HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL="$CHAIN_2_MIN_DENOM_SYMBOL"
export HERMES_CFG_CHAIN_2_DENOM_EXPONENT=$CHAIN_2_DENOM_EXPONENT # no of digits

## Relayer account
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
export BD_PG_DB="bdjuno"
export BD_PG_USER="bdjuno"
export BD_PG_PASS="6N4QtFYMt7h972uazrWTckmMvFZWIje"
export BD_HASURA_BINARY=/usr/local/bin/hasura
export BD_HASURA_SECRET="myadminsecretkey"
export BD_PG_HASURA_META_DB="hasurameta"
export BD_PG_HASURA_DB="hasura"
export BD_PG_HASURA_USER="hasura"
export BD_PG_HASURA_PASS="PX2RNvtZ4m7fntnbRrtySB4ROG5EKk4J"
export BD_CFG_PG_USR_PASS="6N4QtFYMt7h972uazrWTckmMvFZWIje" # Password of default user postgres
### Chain 1
export BD_CFG_CHAIN_1_GIT_REPO="https://github.com/forbole/bdjuno.git"
export BD_CFG_CHAIN_1_BRANCH="chains/evmos/mainnet" # must belong to repo $BD_CFG_CHAIN_1_GIT_REPO
export BD_CFG_CHAIN_1_PG_PORT=5432
export BD_CFG_CHAIN_1_ACCOUNT_PREFIX="$CHAIN_1_ACCOUNT_PREFIX"
export BD_CFG_CHAIN_1_RPC_ADDR="127.0.0.1:$CHAIN_1_EXPOSE_RPC_TO_PORT"
export BD_CFG_CHAIN_1_GRPC_ADDR="127.0.0.1:$CHAIN_1_EXPOSE_GRPC_TO_PORT"
export BD_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export BD_CFG_CHAIN_1_HASURA_PORT=8080
export BD_CFG_CHAIN_1_HASURA_ACTIONBASE_PORT=3000
export BD_CFG_CHAIN_1_DENOM_SYMBOL="$CHAIN_1_DENOM_SYMBOL" # evmos/atom/...
export BD_CFG_CHAIN_1_MIN_DENOM_SYMBOL="$CHAIN_1_MIN_DENOM_SYMBOL" # aevmos/uatom/...
export BD_CFG_CHAIN_1_DENOM_EXPONENT=$CHAIN_1_DENOM_EXPONENT # no of digits (18 for evmos, 6 for cosmos atom)
### Chain 2
export BD_CFG_CHAIN_2_GIT_REPO="https://github.com/forbole/bdjuno.git"
export BD_CFG_CHAIN_2_BRANCH="chains/evmos/mainnet" # must belong to repo $BD_CFG_CHAIN_2_GIT_REPO
export BD_CFG_CHAIN_2_PG_PORT=15432
export BD_CFG_CHAIN_2_ACCOUNT_PREFIX="$CHAIN_2_ACCOUNT_PREFIX"
export BD_CFG_CHAIN_2_RPC_ADDR="127.0.0.1:$CHAIN_2_EXPOSE_RPC_TO_PORT"
export BD_CFG_CHAIN_2_GRPC_ADDR="127.0.0.1:$CHAIN_2_EXPOSE_GRPC_TO_PORT"
export BD_CFG_CHAIN_2_ID="$CHAIN_2_ID"
export BD_CFG_CHAIN_2_HASURA_PORT=8082
export BD_CFG_CHAIN_2_HASURA_ACTIONBASE_PORT=3002
export BD_CFG_CHAIN_2_DENOM_SYMBOL="$CHAIN_2_DENOM_SYMBOL" # evmos/atom/...
export BD_CFG_CHAIN_2_MIN_DENOM_SYMBOL="$CHAIN_2_MIN_DENOM_SYMBOL" # aevmos/uatom...
export BD_CFG_CHAIN_2_DENOM_EXPONENT=$CHAIN_2_DENOM_EXPONENT # no of digits (18 for evmos, 6 for cosmos atom)
### Big Dipper 2.0 for Cosmos based chains
### Chain 1
export BD2_CFG_CHAIN_1_GIT_REPO="https://github.com/forbole/big-dipper-2.0-cosmos.git"
export BD2_CFG_CHAIN_1_BRANCH="chains/evmos"
export BD2_CFG_CHAIN_1_PORT=3800
export BD2_CFG_CHAIN_1_PUBLIC_DOMAIN="127.0.0.1"
export BD2_CFG_CHAIN_1_PUBLIC_RPC_26657="127.0.0.1:$CHAIN_1_EXPOSE_RPC_TO_PORT"
### Chain 2
export BD2_CFG_CHAIN_2_GIT_REPO="https://github.com/forbole/big-dipper-2.0-cosmos.git"
export BD2_CFG_CHAIN_2_BRANCH="chains/evmos"
export BD2_CFG_CHAIN_2_PORT=3802
export BD2_CFG_CHAIN_2_PUBLIC_DOMAIN="127.0.0.1"
export BD2_CFG_CHAIN_2_PUBLIC_RPC_26657="127.0.0.1:$CHAIN_2_EXPOSE_RPC_TO_PORT"

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