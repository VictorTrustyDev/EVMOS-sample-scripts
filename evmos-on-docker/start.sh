#!/bin/bash

source ../env.sh

CHAIN_NO=$1

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Going to start chain $CHAIN_1_ID"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Going to start chain $CHAIN_2_ID"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

docker-compose down -f "network$CHAIN_NO.yml"

docker-compose up -f "network$CHAIN_NO.yml" -d