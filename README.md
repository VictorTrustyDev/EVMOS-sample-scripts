### Here you can find sample scripts and notes of how to [setup multple EVMOS networks](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/tree/main/evmos-on-docker) and [connect them via an IBC relayer (using Hermes)](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/tree/main/hermes-as-ibc-relayer) to transfer tokens & coin cross chain

I wrote hundred lines of comments which explains every steps in each script file and each readme file, hope that helps you guys in exploring Evmos & Cosmos Ecosystem

#### Pre-requisites
- [Go 1.17.5+](https://go.dev/doc/install)
- [jq](https://stedolan.github.io/jq/download)
- [yq + tomlq (build on top of jq)](https://github.com/kislyuk/yq)
- [Rust 1.60+](https://www.rust-lang.org/tools/install) (for Hermes - IBC relayer)

I created all of the following samples on an Ubuntu 22.04 LTS machine with 4 CPU 4 GB RAM. It can run 2 EVMOS networks + 1 Hermes as IBC relayer without any performance issue.

### List of samples:
- [Script to build EVMOS networks and run with docker compose](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/evmos-on-docker)
- [Script to build & setup Hermes as an IBC relayer](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/hermes-as-ibc-relayer)
- [Script to setup bdjuno (back-end of Big Dipper block explorer)](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/bdjuno)

### Software versions:

- [Evmos v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)
- [Hermes v0.15.0](https://github.com/informalsystems/ibc-rs/tree/v0.15.0)

You can change version EVMOS and Hermes by updating file [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh)
- This sample is using keyring `test`, you may need to change to `file` for secure your test env if needed