#!/bin/bash

if [ "$CHAIN_NO" = "1" ]; then
    export CHAIN_TYPE="$CHAIN_1_TYPE"
    export CHAIN_ID="$CHAIN_1_ID"
    export HD_COINTYPE=$CHAIN_1_COINTYPE
    export GIT_BRANCH="$CHAIN_1_GIT_REPO_BRANCH"
    export GIT_REPO="$CHAIN_1_GIT_REPO"
    export DAEMON_BINARY_NAME="$CHAIN_1_DAEMON_BINARY_NAME"
    export DENOM_EXPONENT=$CHAIN_1_DENOM_EXPONENT
    export GAS_DENOM_EXPONENT=$CHAIN_1_GAS_DENOM_EXPONENT
    export DENOM_SYMBOL="$CHAIN_1_DENOM_SYMBOL"
    export MIN_DENOM_SYMBOL="$CHAIN_1_MIN_DENOM_SYMBOL"
    export GAS_DENOM_SYMBOL="$CHAIN_1_GAS_DENOM_SYMBOL"
    export VAL_1_SEED="$VAL_1_CHAIN_1_SEED"
    export VAL_1_PRIVATE_KEY="$VAL_1_CHAIN_1_PRIVATE_KEY"
    export VAL_2_SEED="$VAL_2_CHAIN_1_SEED"
    export VAL_2_PRIVATE_KEY="$VAL_2_CHAIN_1_PRIVATE_KEY"
    export VAL_3_SEED="$VAL_3_CHAIN_1_SEED"
    export VAL_3_PRIVATE_KEY="$VAL_3_CHAIN_1_PRIVATE_KEY"
    export VALIDATOR_IMPORT_TYPE="$CHAIN_1_VALIDATOR_IMPORT_TYPE"
    export ACCOUNT_PREFIX="$CHAIN_1_ACCOUNT_PREFIX"
    export EVMOS_CLAIM_MODULE_ACCOUNT="$EVMOS_CHAIN_1_CLAIM_MODULE_ACCOUNT"
elif [ "$CHAIN_NO" = "2" ]; then
    export CHAIN_TYPE="$CHAIN_2_TYPE"
    export CHAIN_ID="$CHAIN_2_ID"
    export HD_COINTYPE=$CHAIN_2_COINTYPE
    export GIT_BRANCH="$CHAIN_2_GIT_REPO_BRANCH"
    export GIT_REPO="$CHAIN_2_GIT_REPO"
    export DAEMON_BINARY_NAME="$CHAIN_2_DAEMON_BINARY_NAME"
    export DENOM_EXPONENT=$CHAIN_2_DENOM_EXPONENT
    export GAS_DENOM_EXPONENT=$CHAIN_2_GAS_DENOM_EXPONENT
    export DENOM_SYMBOL="$CHAIN_2_DENOM_SYMBOL"
    export MIN_DENOM_SYMBOL="$CHAIN_2_MIN_DENOM_SYMBOL"
    export GAS_DENOM_SYMBOL="$CHAIN_2_GAS_DENOM_SYMBOL"
    export VAL_1_SEED="$VAL_1_CHAIN_2_SEED"
    export VAL_1_PRIVATE_KEY="$VAL_1_CHAIN_2_PRIVATE_KEY"
    export VAL_2_SEED="$VAL_2_CHAIN_2_SEED"
    export VAL_2_PRIVATE_KEY="$VAL_2_CHAIN_2_PRIVATE_KEY"
    export VAL_3_SEED="$VAL_3_CHAIN_2_SEED"
    export VAL_3_PRIVATE_KEY="$VAL_3_CHAIN_2_PRIVATE_KEY"
    export VALIDATOR_IMPORT_TYPE="$CHAIN_2_VALIDATOR_IMPORT_TYPE"
    export ACCOUNT_PREFIX="$CHAIN_2_ACCOUNT_PREFIX"
    export EVMOS_CLAIM_MODULE_ACCOUNT="$EVMOS_CHAIN_2_CLAIM_MODULE_ACCOUNT"
fi

export SOURCE_CODE_DIR="./source-code-$DENOM_SYMBOL-$GIT_BRANCH"
export CHAIN_NAME=$(echo $DENOM_SYMBOL | tr '[:lower:]' '[:upper:]')
export VAL_HOME_PREFIX=".evmosd$CHAIN_NO"
export CHAIN_TYPE=$(echo $CHAIN_TYPE | tr '[:upper:]' '[:lower:]')

if [ "$CHAIN_TYPE" = "evmos" ]; then
    export DISABLE_CLAIM=0
    if [ "$VALIDATOR_IMPORT_TYPE" = "private_key" ] || [ "$VALIDATOR_IMPORT_TYPE" = "pk" ]; then
        echo
    else
        echo "Chain type 'evmos' only supports validator import type = 'private_key' (check variable 'CHAIN_${CHAIN_NO}_VALIDATOR_IMPORT_TYPE') due to bug of daemon can not import seed phrase programatically via command line"
        exit 1
    fi

    if [ "$HD_COINTYPE" -ne "60" ]; then
        echo "Chain type 'evmos' requires coin type 60 (check variable 'CHAIN_${CHAIN_NO}_COINTYPE')"
    fi
else
    export DISABLE_CLAIM=1
    if [ "$VALIDATOR_IMPORT_TYPE" = "seed" ] || [ "$VALIDATOR_IMPORT_TYPE" = "seed_phrase" ] || [ "$VALIDATOR_IMPORT_TYPE" = "sp" ]; then
        echo
    else
        echo "Chain type 'cosmos' only supports validator import type = 'seed_phrase' (check variable 'CHAIN_${CHAIN_NO}_VALIDATOR_IMPORT_TYPE') because the daemon does not support 'unsafe-import-eth-key' command"
        exit 1
    fi
fi

echo "Creating $CHAIN_NAME network with chain id $CHAIN_ID"
echo "- Account prefix: $ACCOUNT_PREFIX"
echo "- Chain type: $CHAIN_TYPE"
echo "- Denom symbol: $DENOM_SYMBOL ($DENOM_EXPONENT digits unit: $MIN_DENOM_SYMBOL, $GAS_DENOM_EXPONENT digits gas unit: $GAS_DENOM_SYMBOL)"
echo "- Source code on repo: $GIT_REPO"
echo "- Source code on branch: $GIT_BRANCH"
echo "- Download source code to dir: $SOURCE_CODE_DIR"
echo "- Expect deamon binary name: $DAEMON_BINARY_NAME"
if [ $DISABLE_CLAIM -eq 0 ]; then
    echo "- Claim module account: $EVMOS_CLAIM_MODULE_ACCOUNT"
fi