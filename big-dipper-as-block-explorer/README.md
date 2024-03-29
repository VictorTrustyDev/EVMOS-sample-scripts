### I. Prepare
- **IMPORTANT** Open file `env.sh`, locate the variables with prefix `BD_CFG_CHAIN_*` and updated based on your need

### II. Create the BDJUNO & Big Dipper 2.0 UI
- Create for chain 1
    > $ ./1_install-bdjuno.sh 1

    > $ ./2_install-bdjuno.sh 1

    > $ ./3_install-hasura.sh 1

    > $ ./4_install-front-end.sh 1

    Frontend port: `3800`

- Create for chain 2
    > $ ./1_install-bdjuno.sh 2

    > $ ./2_install-bdjuno.sh 2

    > $ ./3_install-hasura.sh 2

    > $ ./4_install-front-end.sh 2

    Frontend port: `3802`

### III. Customization
You can custom things just by editting keys in the [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh) file

Here are some of them:

| Key | Default value | Explain |
| --- | --- | --- |
| `BD2_CFG_CHAIN_1_PORT` | 3800 | Port to open Big Dipper 2.0 as Block Explorer UI for chain 1 |
| `BD2_CFG_CHAIN_1_PUBLIC_DOMAIN` | 127.0.0.1 | Domain to bind the UI on (for chain 1) |
| `BD2_CFG_CHAIN_1_PUBLIC_RPC_26657` | 127.0.0.1:26657 | Public RPC endpoint of chain 1 |
| `BD2_CFG_CHAIN_1_PROJECT_NAME` | web-evmos | Chain-specific app dir within [BD2 web ui project](https://github.com/forbole/big-dipper-2.0-cosmos/tree/main/apps) |
| `BD2_CFG_CHAIN_1_CHAIN_NAME` | evmos | Chain name to be set in `./app/web-x/src/chain.json` |
| `BD_CFG_CHAIN_1_HASURA_PORT` | 8080 | Port to open hasura graphql service for chain 1 |
| `BD_CFG_CHAIN_1_HASURA_ACTIONBASE_PORT` | 3000 | Port for bdjuno to open hasura action for chain 1 |
| `BD_CFG_CHAIN_1_PG_PORT` | 5432 | Port to expose bdjuno & hasura's Postgres DB which stores data for chain 1 |
| `BD_CFG_CHAIN_1_RPC_ADDR` | 127.0.0.1:26657 | RPC endpoint of chain 1 |
| `BD_CFG_CHAIN_1_GRPC_ADDR` | 127.0.0.1:9090 | gRPC endpoint of chain 1 |
| `BD_CFG_CHAIN_1_ID` | evmos_9006-1 | Chain id of chain 1 |
| `BD2_CFG_CHAIN_2_PORT` | 3802 | Port to open Big Dipper 2.0 as Block Explorer UI for chain 2 |
| `BD2_CFG_CHAIN_2_PUBLIC_DOMAIN` | 127.0.0.1 | Domain to bind the UI on (for chain 2) |
| `BD2_CFG_CHAIN_2_PUBLIC_RPC_26657` | 127.0.0.1:36657 | Public RPC endpoint of chain 2 |
| `BD2_CFG_CHAIN_2_PROJECT_NAME` | web-evmos | Chain-specific app dir within [BD2 web ui project](https://github.com/forbole/big-dipper-2.0-cosmos/tree/main/apps) |
| `BD2_CFG_CHAIN_2_CHAIN_NAME` | evmos | Chain name to be set in `./app/web-x/src/chain.json` |
| `BD_CFG_CHAIN_2_HASURA_PORT` | 8082 | Port to open hasura graphql service for chain 2 |
| `BD_CFG_CHAIN_2_HASURA_ACTIONBASE_PORT` | 3002 | Port for bdjuno to open hasura action for chain 2 |
| `BD_CFG_CHAIN_2_PG_PORT` | 15432 | Port to expose bdjuno & hasura's Postgres DB which stores data for chain 2 |
| `BD_CFG_CHAIN_2_RPC_ADDR` | 127.0.0.1:36657 | RPC endpoint of chain 2 |
| `BD_CFG_CHAIN_2_GRPC_ADDR` | 127.0.0.1:19090 | gRPC endpoint of chain 2 |
| `BD_CFG_CHAIN_2_ID` | evmos_9007-1 | Chain id of chain 2 |
