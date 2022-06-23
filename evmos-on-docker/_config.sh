#!/bin/bash

if [ "$CHAIN_NO" = "1" ]; then
    export CHAIN_ID="$CHAIN_1_ID"
    export EVMOS_REPO="$EVMOS_CHAIN_1_REPO"
    export EVMOS_VER="$EVMOS_CHAIN_1_BRANCH"
    export EVMOS_DAEMON="$EVMOS_CHAIN_1_DAEMON"
    export EVMOS_CLAIM_MODULE_ACCOUNT="$EVMOS_CHAIN_1_CLAIM_MODULE_ACCOUNT"
    export EVMOS_DENOM_EXPONENT=$EVMOS_CHAIN_1_DENOM_EXPONENT
    export EVMOS_GAS_DENOM_EXPONENT=$EVMOS_CHAIN_1_GAS_DENOM_EXPONENT
    export DENOM_SYMBOL="$EVMOS_CHAIN_1_DENOM_SYMBOL"
    export MIN_DENOM_SYMBOL="$EVMOS_CHAIN_1_MIN_DENOM_SYMBOL"
    export GAS_DENOM_SYMBOL="$EVMOS_CHAIN_1_GAS_DENOM_SYMBOL"
elif [ "$CHAIN_NO" = "2" ]; then
    export CHAIN_ID="$CHAIN_2_ID"
    export EVMOS_REPO="$EVMOS_CHAIN_2_REPO"
    export EVMOS_VER="$EVMOS_CHAIN_2_BRANCH"
    export EVMOS_DAEMON="$EVMOS_CHAIN_2_DAEMON"
    export EVMOS_CLAIM_MODULE_ACCOUNT="$EVMOS_CHAIN_2_CLAIM_MODULE_ACCOUNT"
    export EVMOS_DENOM_EXPONENT=$EVMOS_CHAIN_2_DENOM_EXPONENT
    export EVMOS_GAS_DENOM_EXPONENT=$EVMOS_CHAIN_2_GAS_DENOM_EXPONENT
    export DENOM_SYMBOL="$EVMOS_CHAIN_2_DENOM_SYMBOL"
    export MIN_DENOM_SYMBOL="$EVMOS_CHAIN_2_MIN_DENOM_SYMBOL"
    export GAS_DENOM_SYMBOL="$EVMOS_CHAIN_2_GAS_DENOM_SYMBOL"
fi

export EVMOS_SOURCE_DIR="./EVMOS-source-code-$EVMOS_VER"
export EVMOS_CHAINNAME=$(echo $DENOM_SYMBOL | tr '[:lower:]' '[:upper:]')
export VAL_HOME_PREFIX='.evmosd'$CHAIN_NO

echo "Creating EVMOS network with chain id $CHAIN_ID"
echo "- Denom symbol: $DENOM_SYMBOL ($EVMOS_DENOM_EXPONENT digits unit: $MIN_DENOM_SYMBOL, $EVMOS_GAS_DENOM_EXPONENT digits gas unit: $GAS_DENOM_SYMBOL)"
echo "- Source code on repo: $EVMOS_REPO"
echo "- Source code on branch: $EVMOS_VER"
echo "- Download source code to dir: $EVMOS_SOURCE_DIR"
echo "- Expect deamon: $EVMOS_DAEMON"
echo "- Claim module account: $EVMOS_CLAIM_MODULE_ACCOUNT"
