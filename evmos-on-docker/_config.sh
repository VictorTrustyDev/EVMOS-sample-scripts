#!/bin/bash

if [ "$CHAIN_NO" = "1" ]; then
    export CHAIN_ID="$CHAIN_1_ID"
elif [ "$CHAIN_NO" = "2" ]; then
    export CHAIN_ID="$CHAIN_2_ID"
fi

