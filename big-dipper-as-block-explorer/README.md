### I. Prepare
- **IMPORTANT** Open file `env.sh`, locate the variables with prefix `BD_CFG_CHAIN_*` and updated based on your need

### II. Create the BDJUNO
- Create network 1
    - Create & setup PG database, init bdjuno home `.bdjuno1`, update `.bdjuno1/config.yaml` file
    > $ ./1_install-bdjuno.sh 1

    - Copy `genesis.json` file into bdjuno home at `.bdjuno1` & parse it
    > $ ./2_install-bdjuno.sh 1

    - Run `hasura` graphql service and expose port `8080`
    > $ ./3_install-hasura.sh 1

    - Hasura will open graphql service for network 1 at port 8080

- Create network 2
    - Create & setup PG database, init bdjuno home `.bdjuno2`, update `.bdjuno2/config.yaml` file
    > $ ./1_install-bdjuno.sh 2

    - Copy `genesis.json` file into bdjuno home at `.bdjuno2` & parse it
    > $ ./2_install-bdjuno.sh 2

    - Run `hasura` graphql service and expose port
    > $ ./3_install-hasura.sh 2

    - Hasura will open graphql service for network 2 at port 8082

### III. Customization
You can custom things just by editting keys in the [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh) file

Here are some of them:

| Key | Default value | Explain |
| --- | --- | --- |
| `BD_CFG_CHAIN_1_HASURA_PORT` | 8080 | Port to open hasura graphql service for network 1 |
| `BD_CFG_CHAIN_1_HASURA_ACTIONBASE_PORT` | 3000 | Port for bdjuno to open hasura action for network 1 |
| `BD_CFG_CHAIN_1_PG_PORT` | 5432 | Port to expose bdjuno & hasura's Postgres DB which stores data for network 1 |
| `BD_CFG_CHAIN_1_RPC_ADDR` | 127.0.0.1:26657 | RPC endpoint of network 1 |
| `BD_CFG_CHAIN_1_GRPC_ADDR` | 127.0.0.1:9090 | gRPC endpoint of network 1 |
| `CHAIN_1_ID` | evmos_9006-1 | Chain id of network 1 |
| `BD_CFG_CHAIN_2_HASURA_PORT` | 8082 | Port to open hasura graphql service for network 2 |
| `BD_CFG_CHAIN_2_HASURA_ACTIONBASE_PORT` | 3002 | Port for bdjuno to open hasura action for network 2 |
| `BD_CFG_CHAIN_2_PG_PORT` | 15432 | Port to expose bdjuno & hasura's Postgres DB which stores data for network 2 |
| `BD_CFG_CHAIN_2_RPC_ADDR` | 127.0.0.1:36657 | RPC endpoint of network 2 |
| `BD_CFG_CHAIN_2_GRPC_ADDR` | 127.0.0.1:19090 | gRPC endpoint of network 2 |
| `CHAIN_2_ID` | evmos_9007-1 | Chain id of network 2 |