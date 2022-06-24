#!/bin/bash

# You can rename this file into `override-env.sh` to make the first network become cosmos

export KEYRING="file"

export CHAIN_1_ID="cosmos-8"
export CHAIN_1_COINTYPE=118
export CHAIN_1_VALIDATOR_IMPORT_TYPE="seed_phrase"
export EVMOS_CHAIN_1_REPO="https://github.com/cosmos/gaia"
export EVMOS_CHAIN_1_BRANCH="v7.0.2"
export EVMOS_CHAIN_1_DAEMON="gaiad"
export EVMOS_CHAIN_1_DENOM_SYMBOL="atom"
export EVMOS_CHAIN_1_MIN_DENOM_SYMBOL="uatom"
export EVMOS_CHAIN_1_GAS_DENOM_SYMBOL="natom"
export EVMOS_CHAIN_1_DENOM_EXPONENT=6
export EVMOS_CHAIN_1_GAS_DENOM_EXPONENT=3
export EVMOS_CHAIN_1_ACCOUNT_PREFIX="cosmos"
export EVMOS_CHAIN_1_CLAIM_MODULE_ACCOUNT="cosmos14eadktsf4zzah6har7h7a46tunnj7rq7lmppy5" # whatever, as long as it is different than 3 validators and the relayer account
export VAL_1_CHAIN_1_ADDR="cosmos1r0ku6275wrtud9vtvzulvgrk8vznan7xzeuepz"
export VAL_2_CHAIN_1_ADDR="cosmos1fwqsdptgfvtjvhxu2eem3pgvjwn3yup24n75kh"
export VAL_3_CHAIN_1_ADDR="cosmos1czg02jwz4rvu405mzxnw7h9zkzu7pm39wl6h5e"
export REL_1_ADDR="cosmos16euecy8mnkhdpnr4y3346h44v0gqj67zwc4laf"
export HERMES_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export HERMES_CFG_CHAIN_1_ACCOUNT_PREFIX="$EVMOS_CHAIN_1_ACCOUNT_PREFIX"
export HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL="$EVMOS_CHAIN_1_MIN_DENOM_SYMBOL"
export HERMES_CFG_CHAIN_1_DENOM_EXPONENT=$EVMOS_CHAIN_1_DENOM_EXPONENT # no of digits
export BD_CFG_CHAIN_1_BRANCH="chains/cosmos/mainnet"
export BD_CFG_CHAIN_1_ACCOUNT_PREFIX="$EVMOS_CHAIN_1_ACCOUNT_PREFIX"
export BD_CFG_CHAIN_1_ID="$CHAIN_1_ID"
export BD_CFG_CHAIN_1_DENOM_SYMBOL="$EVMOS_CHAIN_1_DENOM_SYMBOL"
export BD_CFG_CHAIN_1_MIN_DENOM_SYMBOL="$EVMOS_CHAIN_1_MIN_DENOM_SYMBOL"
export BD_CFG_CHAIN_1_DENOM_EXPONENT=$EVMOS_CHAIN_1_DENOM_EXPONENT
export BD2_CHAIN_1_BRANCH="chains/cosmos"
~