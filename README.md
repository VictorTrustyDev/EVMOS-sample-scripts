### Here you can find sample scripts and notes of how to [setup multple EVMOS networks](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/tree/main/evmos-on-docker) and [connect them via an IBC relayer (using Hermes)](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/tree/main/hermes-as-ibc-relayer) to transfer tokens & coin cross chain

I wrote hundred lines of comments which explains every steps in each script file and each readme file, hope that helps you guys in exploring Evmos & Cosmos Ecosystem

#### Pre-requisites
- [Go 1.17.5+](https://go.dev/doc/install)
- [jq](https://stedolan.github.io/jq/download)
- [yq + tomlq (build on top of jq)](https://github.com/kislyuk/yq)
- [Rust 1.60+](https://www.rust-lang.org/tools/install) (for Hermes - IBC relayer)
- [docker](https://docs.docker.com/engine/install/) & [docker compose](https://docs.docker.com/compose/install/)

I created all of the following samples on an Ubuntu 22.04 LTS machine with 4 CPU 4 GB RAM. It can run 
- 2 EVMOS networks
- 1 Hermes as IBC relayer to connect them
- 2 bdjuno as block explorer's backend
- 2 hasura as graphql service

without any performance issue (CPU ~20% per core, ram ~45% via htop).

### List of samples:
- [Script to build EVMOS networks and run with docker compose](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/evmos-on-docker)
- [Script to build & setup Hermes as an IBC relayer](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/hermes-as-ibc-relayer)
- [Script to setup bdjuno (back-end of Big Dipper block explorer) with hasura as graphql service](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/bdjuno)

### Software versions:

- [Evmos v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)
- [Hermes v0.15.0](https://github.com/informalsystems/ibc-rs/tree/v0.15.0)

You can change version EVMOS and Hermes by updating file [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh)
- This sample is using keyring `test`, you may need to change to `file` for secure your test env if needed
- You can create `override-env.sh` file and override values there (git ignores this file)

#### Default ports used in these samples

| Sample name | Port No. for network 1 | Port No. for network 2 | Desc |
| --- | --- | --- | --- |
| EVMOS on docker | 26657 | 36657 | RPC |
| EVMOS on docker | 8545 | 18545 | Json RPC |
| EVMOS on docker | 1317 | 11317 | REST API |
| EVMOS on docker | 9090 | 19090 | gRPC |
| EVMOS on docker | 26656 | 36656 | P2P |
| bdjuno | 8080 | 8082 | Hasura's graphql service |
| bdjuno | 3000 | 3002 | bdjuno hasura action base |

#### Default service name & container name used in these samples
| Sample name | Name for network 1 | Name for network 2 | Desc |
| --- | --- | --- | --- |
| EVMOS on docker | vtevmos10 | vtevmos20 | Node 0 (validator 1) of EVMOS network run via docker-compose |
| EVMOS on docker | vtevmos11 | vtevmos21 | Node 1 (validator 2) of EVMOS network run via docker-compose |
| EVMOS on docker | vtevmos12 | vtevmos22 | Node 2 (validator 3) of EVMOS network run via docker-compose |
| Hermes as IBC relayer | (hermes-svc as a shared service) | (hermes-svc as a shared service) | Hermes connects both networks (Debian* daemon service) |
| bdjuno | bdjuno-svc1 | bdjuno-svc2 | bdjuno app (Debian* daemon service) |
| bdjuno | bdjdb1 | bdjdb2 | bdjuno & hasura database |
| bdjuno | bdjhasura1 | bdjhasura2 | Hasura graphql service |