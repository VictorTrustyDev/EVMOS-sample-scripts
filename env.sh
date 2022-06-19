#!/bin/bash

# Pre-requisites
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }
command -v yq > /dev/null 2>&1 || { echo >&2 "yq not installed. More info: https://github.com/kislyuk/yq/. Hint: sudo apt install python3-pip -y && pip3 install yq"; exit 1; }
command -v tomlq > /dev/null 2>&1 || { echo >&2 "tomlq not installed, it is expected to be delivered within yq package"; exit 1; }
command -v bc > /dev/null 2>&1 || { echo >&2 "bc command could not be found"; exit 1; }
command -v make > /dev/null 2>&1 || { echo >&2 "make command could not be found"; exit 1; }
command -v go > /dev/null 2>&1 || { echo >&2 "go was not installed"; exit 1; }

# Configurations

export KEYRING="test" # change to file for cloud or production env (DANGER: keyring test will allow transfer token from validator without key)

## IP addresses
export IP_EVMOS_1_INT="evmos1i.victortrusty.dev"
export IP_EVMOS_2_INT="evmos2i.victortrusty.dev"
export IP_EVMOS_3_INT="evmos3i.victortrusty.dev"

## EVMOS (network)
export EVMOS_VER="v5.0.0"
export EVMOS_BINARY="evmosd"
export EVMOS_DENOM_EXPONENT=18 # no of digits
export EVMOS_SOURCE_DIR="EVMOS-source-code"

## Validators
export VAL_RAW_BALANCE=50000000 # Init with 50m EVMOS in balance for each validator
export VAL_RAW_STAKE=5000000 # Each validator will stake 5m EVMOS
### Validator 1
export VAL_1_KEY_NAME="val1"
export VAL_1_SEED="spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi"
export VAL_1_ADDR="evmos1wuqvcpuunf7r5rg7xutqddhw55grfzc75qejyq"
### Validator 2
export VAL_2_KEY_NAME="val2"
export VAL_2_SEED="width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle"
export VAL_2_ADDR="evmos1zxgt4pwzzsv02z24g80lc5rhtsp0prw0c5tk3d"
### Validator 3
export VAL_3_KEY_NAME="val3"
export VAL_3_SEED="stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father"
export VAL_3_ADDR="evmos1vcy9v4jp0sd4hysqqcuwleytxre3ms4ckzmdnz"

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
export HERMES_SOURCE_DIR="Hermes-source-code"

## Relayer account
export REL_KEY_NAME="default"
### Chain 1
export REL_1_SEED="raw course slim hockey salt crawl sick safe december during armed fragile"
export REL_1_ADDR="evmos1metw56lk3k4vhkh0vzxlr8p4mzpjvttmagvekp"
### Chain 2
export REL_2_SEED="above name soft reunion change cabin rack outside wedding orange dice impact"
export REL_2_ADDR="evmos157g0zpv77su6awh04wec5s2jdyrk62jy40ck58"

## Reflects by above config (edit at your own risk)
export EVMOS_CHAINNAME=$(echo $DENOM_SYMBOL | tr '[:lower:]' '[:upper:]')
export EVMOS_MONIKER=$DENOM_SYMBOL'AIO'
export EVMOS_SERVICE_NAME=$EVMOS_BINARY'-svc'
export HERMES_SERVICE_NAME=$HERMES_BINARY'-svc'
### Validators
#### Balance
export VAL_1_BALANCE=$(bc <<< "10^$EVMOS_DENOM_EXPONENT * $VAL_RAW_BALANCE")
export VAL_2_BALANCE=$VAL_1_BALANCE
export VAL_3_BALANCE=$VAL_1_BALANCE
#### Stake
export VAL_1_STAKE=$(bc <<< "10^$EVMOS_DENOM_EXPONENT * $VAL_RAW_STAKE")
export VAL_2_STAKE=$VAL_1_STAKE
export VAL_3_STAKE=$VAL_1_STAKE