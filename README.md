### Here you can find sample scripts and notes of how to [setup multiple EVMOS chains](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/tree/main/blockchain-in-docker) and [connect them via an IBC (using Hermes as relayer)](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/tree/main/hermes-as-ibc-relayer) to transfer tokens & coin cross chain

I wrote hundred lines of comments which explains every steps in each script file and each readme file, hope that helps you guys in exploring Evmos & Cosmos Ecosystem

Not only EVMOS, you can use this script to build for other chains like cosmos,... Look at [this](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/sample.cosmos-and-evmos.override-env.sh) to know how to do it

#### Pre-requisites
- [Go 1.17.5+](https://go.dev/doc/install)
- [jq](https://stedolan.github.io/jq/download)
- [yq + tomlq (build on top of jq)](https://github.com/kislyuk/yq)
- [Rust 1.60+](https://www.rust-lang.org/tools/install) (for Hermes - IBC relayer)
- [docker](https://docs.docker.com/engine/install/) & [docker compose](https://docs.docker.com/compose/install/)
- Node JS (for Big Dipper 2.0 Cosmos)

I created all of the following samples on an Ubuntu 22.04 LTS machine with 4 CPU 16 GB RAM. It can run 
- 2 [EVMOS](https://github.com/evmos/evmos/tree/v5.0.0) chains
- 1 [Hermes](https://github.com/informalsystems/ibc-rs/tree/v0.15.0) as IBC relayer to connect them
- 2 [bdjuno & hasura](https://github.com/forbole/bdjuno/tree/chains/evmos/mainnet) as block explorer's backend & graphql service
- 2 [Big Dipper 2.0](https://github.com/forbole/big-dipper-2.0-cosmos/tree/chains/evmos) as block explorer's backend

without any performance issue (CPU ~20-80% per core, ram ~50% via htop).

### List of samples:
- [Script to build EVMOS chains and run with docker compose](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/blockchain-in-docker)
- [Script to build & setup Hermes as an IBC relayer](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/hermes-as-ibc-relayer)
- [Script to setup Big Dipper (backend bdjuno with hasura as graphql service & frontend Big Dipper 2.0 for Cosmos based chains)](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/big-dipper-as-block-explorer)

### Software versions:

- [Evmos v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)
- [Hermes v0.15.0](https://github.com/informalsystems/ibc-rs/tree/v0.15.0)
- [bdjuno branch evmos](https://github.com/forbole/bdjuno/tree/chains/evmos/mainnet)
- [Big Dipper 2.0 for Cosmos chains branch evmos](https://github.com/forbole/big-dipper-2.0-cosmos/tree/chains/evmos)

#### Customization
- You can change their version by updating file [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh)
- This sample is using keyring `test`, you may need to change to `file` for secure your test env if needed in [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh)
- You can create `override-env.sh` file and override values of [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh)
- The [sample.cosmos-and-evmos.override-env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/sample.cosmos-and-evmos.override-env.sh) file contains example which tell you how to override variables of [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh) and make the chain 1 use cosmos source, rename it to `override-env.sh` to make it effectives
- The [sample.expose-big-dipper-ui.override-env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/sample.expose-big-dipper-ui.override-env.sh) file contains example which tell you how to override variables of [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh) and make the block explorer UI (Big Dipper 2.0) accessible from outside world, rename it to `override-env.sh` to make it effectives

#### Default ports used in these samples

| Sample name | Port No. for chain 1 | Port No. for chain 2 | Desc |
| --- | --- | --- | --- |
| EVMOS on docker | 26657 | 36657 | **RPC** |
| EVMOS on docker | 8545 | 18545 | **Json RPC** |
| EVMOS on docker | 1317 | 11317 | **REST API** |
| EVMOS on docker | 9090 | 19090 | gRPC |
| EVMOS on docker | 26656 | 36656 | P2P |
| Big Dipper as Block Explorer | 3800 | 3802 | **Big Dipper front end** |
| Big Dipper as Block Explorer | 8080 | 8082 | Hasura's graphql service |
| Big Dipper as Block Explorer | 3000 | 3002 | bdjuno hasura action base |

#### Default service name & container name used in these samples
| Sample name | Name for chain 1 | Name for chain 2 | Desc |
| --- | --- | --- | --- |
| EVMOS on docker | vtevmos10 | vtevmos20 | Node 0 (validator 1) of EVMOS chain run via docker-compose |
| EVMOS on docker | vtevmos11 | vtevmos21 | Node 1 (validator 2) of EVMOS chain run via docker-compose |
| EVMOS on docker | vtevmos12 | vtevmos22 | Node 2 (validator 3) of EVMOS chain run via docker-compose |
| Hermes as IBC relayer | (hermes-svc as a shared service for both chains) | (hermes-svc as a shared service) | Hermes connects both chains (Debian* daemon service) |
| Big Dipper as Block Explorer | bdjuno-svc1 | bdjuno-svc2 | bdjuno app (Debian* daemon service) |
| Big Dipper as Block Explorer | bdjdb1 | bdjdb2 | bdjuno & hasura database (docker) |
| Big Dipper as Block Explorer | bdjhasura1 | bdjhasura2 | Hasura graphql service (docker) |
| Big Dipper as Block Explorer | bd2-svc1 | bd2-svc2 | Big Dipper front end (Debian* daemon service) |

`(Not recommended) Tips:` There is script named [all-in-one.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/all-in-one.sh), if you are using an OS which supports `systemd` and some required tools, you can create everything just by running this script (EVMOS x2 + Big Dipper x2 + Hermes)