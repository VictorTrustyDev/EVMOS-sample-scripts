#!/bin/bash

if [ "$CHAIN_NO" = "1" ]; then
    export CHAIN_ID="$BD_CFG_CHAIN_1_ID"
    export PG_PORT=$BD_CFG_CHAIN_1_PG_PORT
    export ACCOUNT_PREFIX=$BD_CFG_CHAIN_1_ACCOUNT_PREFIX
    export RPC_ADDR=$BD_CFG_CHAIN_1_RPC_ADDR
    export GRPC_ADDR=$BD_CFG_CHAIN_1_GRPC_ADDR
elif [ "$CHAIN_NO" = "2" ]; then
    export CHAIN_ID="$BD_CFG_CHAIN_2_ID"
    export PG_PORT=$BD_CFG_CHAIN_2_PG_PORT
    export ACCOUNT_PREFIX=$BD_CFG_CHAIN_2_ACCOUNT_PREFIX
    export RPC_ADDR=$BD_CFG_CHAIN_2_RPC_ADDR
    export GRPC_ADDR=$BD_CFG_CHAIN_2_GRPC_ADDR
fi

echo "Creating bdjuno for $CHAIN_ID"
echo "- RPC: $RPC_ADDR"
echo "- gRPC: $GRPC_ADDR"
echo "- Postgres port: $PG_PORT"
echo "- Account prefix: $ACCOUNT_PREFIX"

export BD_HOME=$(pwd)"/.bdjuno$CHAIN_NO"
export BD_SERVICE_NAME="bdjuno-svc$CHAIN_NO"