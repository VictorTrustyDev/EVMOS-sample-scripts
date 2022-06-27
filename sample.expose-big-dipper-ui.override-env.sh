#!/bin/bash

# You can rename this file into `override-env.sh` to make the block explorer become accessible from outside world
# Use a domain that does not force https (like .dev, .world,...) because all expose ports of this project is http only

export KEYRING="file" # Secure your chain otherwise someone will absolutely transfer your token without your permission if you use keyring 'test'
export VAL_KEYRING_FILE_ENCRYPTION_PASSWORD="11111111"

export BD2_CFG_CHAIN_1_PUBLIC_DOMAIN="bigdipper.example.com"
export BD2_CFG_CHAIN_1_PUBLIC_RPC_26657="rpc.example.com:$CHAIN_1_EXPOSE_RPC_TO_PORT"

export BD2_CFG_CHAIN_2_PUBLIC_DOMAIN="bigdipper.example.com"
export BD2_CFG_CHAIN_2_PUBLIC_RPC_26657="rpc.example.com:$CHAIN_2_EXPOSE_RPC_TO_PORT"