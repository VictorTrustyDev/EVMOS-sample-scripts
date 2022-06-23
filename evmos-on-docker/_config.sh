#!/bin/bash

if [ "$CHAIN_NO" = "1" ]; then
    export CHAIN_ID="$CHAIN_1_ID"
    export EVMOS_REPO="$EVMOS_CHAIN_1_REPO"
    export EVMOS_VER="$EVMOS_CHAIN_1_BRANCH"
    export EVMOS_DAEMON="$EVMOS_CHAIN_1_DAEMON"
    export EVMOS_CLAIM_MODULE_ACCOUNT="$EVMOS_CHAIN_1_CLAIM_MODULE_ACCOUNT"
    export EVMOS_DENOM_EXPONENT=$EVMOS_CHAIN_1_DENOM_EXPONENT
elif [ "$CHAIN_NO" = "2" ]; then
    export CHAIN_ID="$CHAIN_2_ID"
    export EVMOS_REPO="$EVMOS_CHAIN_2_REPO"
    export EVMOS_VER="$EVMOS_CHAIN_2_BRANCH"
    export EVMOS_DAEMON="$EVMOS_CHAIN_2_DAEMON"
    export EVMOS_CLAIM_MODULE_ACCOUNT="$EVMOS_CHAIN_2_CLAIM_MODULE_ACCOUNT"
    export EVMOS_DENOM_EXPONENT=$EVMOS_CHAIN_2_DENOM_EXPONENT
fi

export EVMOS_SOURCE_DIR="./EVMOS-source-code-$EVMOS_VER"

echo "Creating EVMOS network with chain id $CHAIN_ID"
echo "- Source code on repo: $EVMOS_REPO"
echo "- Source code on branch: $EVMOS_VER"
echo "- Download source code to dir: $EVMOS_SOURCE_DIR"
echo "- Expect deamon: $EVMOS_DAEMON"
echo "- Claim module account: $EVMOS_CLAIM_MODULE_ACCOUNT"
echo "- Denom exponent: $EVMOS_DENOM_EXPONENT digits"
