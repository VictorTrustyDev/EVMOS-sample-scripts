#!/bin/bash

# You can rename this file into `override-env.sh` to make the block explorer become accessible from outside world
# Use a domain that does not force https (like .dev, .world,...) because all expose ports of this project is http only

export KEYRING="file" # Secure your chain, someone will absolutely transfer your token without your permission

export BD2_CFG_CHAIN_1_PUBLIC_DOMAIN="bigdipper.example.com"
export BD2_CFG_CHAIN_1_PUBLIC_RPC_26657="rpc.example.com:$EVMOS_CHAIN_1_PORT_RPC"

export BD2_CFG_CHAIN_2_PUBLIC_DOMAIN="bigdipper.example.com"
export BD2_CFG_CHAIN_2_PUBLIC_RPC_26657="rpc.example.com:$EVMOS_CHAIN_2_PORT_RPC"