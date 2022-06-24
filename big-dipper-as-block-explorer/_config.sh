#!/bin/bash

if [ "$CHAIN_NO" = "1" ]; then
    export CHAIN_ID="$BD_CFG_CHAIN_1_ID"
    export PG_PORT=$BD_CFG_CHAIN_1_PG_PORT
    export ACCOUNT_PREFIX=$BD_CFG_CHAIN_1_ACCOUNT_PREFIX
    export RPC_ADDR=$BD_CFG_CHAIN_1_RPC_ADDR
    export GRPC_ADDR=$BD_CFG_CHAIN_1_GRPC_ADDR
    export BD_BRANCH="$BD_CFG_CHAIN_1_BRANCH"
    export BD_HASURA_PORT=$BD_CFG_CHAIN_1_HASURA_PORT
    export BD_HASURA_ACTIONBASE_PORT=$BD_CFG_CHAIN_1_HASURA_ACTIONBASE_PORT
    export DENOM_SYMBOL="$BD_CFG_CHAIN_1_DENOM_SYMBOL"
    export DENOM_EXPONENT=$BD_CFG_CHAIN_1_DENOM_EXPONENT
    export MIN_DENOM_SYMBOL="$BD_CFG_CHAIN_1_MIN_DENOM_SYMBOL"
    export BD2_BRANCH="$BD2_CHAIN_1_BRANCH"
    export BD2_PORT=$BD2_CFG_CHAIN_1_PORT
    export BD2_PUBLIC_DOMAIN="$BD2_CFG_CHAIN_1_PUBLIC_DOMAIN"
    export BD2_PUBLIC_RPC_26657="$BD2_CFG_CHAIN_1_PUBLIC_RPC_26657"
elif [ "$CHAIN_NO" = "2" ]; then
    export CHAIN_ID="$BD_CFG_CHAIN_2_ID"
    export PG_PORT=$BD_CFG_CHAIN_2_PG_PORT
    export ACCOUNT_PREFIX=$BD_CFG_CHAIN_2_ACCOUNT_PREFIX
    export RPC_ADDR=$BD_CFG_CHAIN_2_RPC_ADDR
    export GRPC_ADDR=$BD_CFG_CHAIN_2_GRPC_ADDR
    export BD_BRANCH="$BD_CFG_CHAIN_2_BRANCH"
    export BD_HASURA_PORT=$BD_CFG_CHAIN_2_HASURA_PORT
    export BD_HASURA_ACTIONBASE_PORT=$BD_CFG_CHAIN_2_HASURA_ACTIONBASE_PORT
    export DENOM_SYMBOL="$BD_CFG_CHAIN_2_DENOM_SYMBOL"
    export DENOM_EXPONENT=$BD_CFG_CHAIN_2_DENOM_EXPONENT
    export MIN_DENOM_SYMBOL="$BD_CFG_CHAIN_2_MIN_DENOM_SYMBOL"
    export BD2_BRANCH="$BD2_CHAIN_2_BRANCH"
    export BD2_PORT=$BD2_CFG_CHAIN_2_PORT
    export BD2_PUBLIC_DOMAIN="$BD2_CFG_CHAIN_2_PUBLIC_DOMAIN"
    export BD2_PUBLIC_RPC_26657="$BD2_CFG_CHAIN_2_PUBLIC_RPC_26657"
fi

echo "Creating big dipper as block explorer for $CHAIN_ID"
echo "- Denom: $DENOM_SYMBOL ($DENOM_EXPONENT digits unit: $MIN_DENOM_SYMBOL)"
echo "- RPC: $RPC_ADDR"
echo "- gRPC: $GRPC_ADDR"
echo "- Postgres port: $PG_PORT"
echo "- Account prefix: $ACCOUNT_PREFIX"
echo "- Expose UI at port: $BD2_PORT"

export BD_HOME=$(pwd)"/.bdjuno$CHAIN_NO"
export BD_SERVICE_NAME="bdjuno-svc$CHAIN_NO"
export BD_SOURCE_DIR="source-code-bdjuno-$DENOM_SYMBOL-$CHAIN_NO"
export BD2_SERVICE_NAME="bd2-svc$CHAIN_NO"
export BD2_SOURCE_DIR="source-code-bd2-$DENOM_SYMBOL-$CHAIN_NO"
export BD_BINARY="$GOPATH/bin/bdjuno$CHAIN_NO"