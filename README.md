### Here you can find sample scripts and notes of how to setup an EVMOS network and create IBC relayer (using Hermes) to transfer tokens & coin between networks

#### Pre-requisites
- [Go 1.17.5+](https://go.dev/doc/install)
- [jq](https://stedolan.github.io/jq/download)
- [yq + tomlq (build on top of jq)](https://github.com/kislyuk/yq)
- Rust (for Hermes - IBC relayer)

I created all of the following sample on a Ubuntu 22.04 LTS

### List of samples:
- [Script to build docker image and run with docker compose](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/evmos-on-docker)
- [Script to install EVMOS into your machine (non-Docker)](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/evmos-on-machine)

### Software versions:

- [Evmos v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)
- [Hermes v0.15.0](https://github.com/informalsystems/ibc-rs/tree/v0.15.0)

You can change version EVMOS and Hermes by updating file [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh)
