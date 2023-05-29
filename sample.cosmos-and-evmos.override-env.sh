#!/bin/bash

# You can rename this file into `override-env.sh` to make the first network become Cosmos (gaia)

export KEYRING="file" # Secure your chain otherwise someone will absolutely transfer your token without your permission if you use keyring 'test'
export VAL_KEYRING_FILE_ENCRYPTION_PASSWORD="11111111"

export CHAIN_1_TYPE="cosmos" # valid values are 'evmos' or 'cosmos' only, must be 'evmos' for evmos chain, otherwise 'cosmos' for other chains
export CHAIN_1_ID="cosmos-8"
export CHAIN_1_COINTYPE=118 # 60 for EVMOS, 118 for Cosmos
export CHAIN_1_ACCOUNT_PREFIX="cosmos"
export CHAIN_1_GIT_REPO="https://github.com/cosmos/gaia"
export CHAIN_1_GIT_REPO_BRANCH="v10.0.0"
export CHAIN_1_DAEMON_BINARY_NAME="gaiad"
export CHAIN_1_DENOM_SYMBOL="atom"
export CHAIN_1_MIN_DENOM_SYMBOL="uatom"
export CHAIN_1_GAS_DENOM_SYMBOL="natom"
export CHAIN_1_DENOM_EXPONENT=6
export CHAIN_1_GAS_DENOM_EXPONENT=3

export REL_1_SEED="raw course slim hockey salt crawl sick safe december during armed fragile"
export REL_1_ADDR="cosmos16euecy8mnkhdpnr4y3346h44v0gqj67zwc4laf" # Wallet address of the above seed on Cosmos chain

# IBC Hermes
export HERMES_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export HERMES_CFG_CHAIN_1_ACCOUNT_PREFIX="$CHAIN_1_ACCOUNT_PREFIX"
export HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL="$CHAIN_1_MIN_DENOM_SYMBOL"
export HERMES_CFG_CHAIN_1_DENOM_EXPONENT=$CHAIN_1_DENOM_EXPONENT # no of digits

# Big Dipper
export BD_CFG_CHAIN_1_GIT_REPO="https://github.com/forbole/bdjuno.git"
export BD_CFG_CHAIN_1_GIT_REPO_BRANCH="chains/cosmos/mainnet"
export BD_CFG_CHAIN_1_ACCOUNT_PREFIX="$CHAIN_1_ACCOUNT_PREFIX"
export BD_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export BD_CFG_CHAIN_1_DENOM_SYMBOL="$CHAIN_1_DENOM_SYMBOL"
export BD_CFG_CHAIN_1_MIN_DENOM_SYMBOL="$CHAIN_1_MIN_DENOM_SYMBOL"
export BD_CFG_CHAIN_1_DENOM_EXPONENT=$CHAIN_1_DENOM_EXPONENT
export BD2_CFG_CHAIN_1_GIT_REPO="https://github.com/forbole/big-dipper-2.0-cosmos.git"
export BD2_CFG_CHAIN_1_BRANCH="web-cosmos@2.15.1"
export BD2_CFG_CHAIN_1_PROJECT_NAME="web-cosmos"
export BD2_CFG_CHAIN_1_CHAIN_NAME="cosmos"
