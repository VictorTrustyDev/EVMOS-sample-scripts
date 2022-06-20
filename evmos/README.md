### This sample will create a simple EVMOS network with 1 validator pre-defined, script supports add 2 more validators

#### Step 1: create an EVMOS network
> $ ./create-network-on-machine.sh 1

The network will have following stats:
- Home dir:
 + Network 1: ~/.evmosd-v-evmos_9006-1-node*
 + Network 2: ~/.evmosd-v-evmos_9007-1-node*
- Node 0 (1st/genesis validator) will public the following ports to 0.0.0.0 network interface:
 + 1317 for REST API
 + 26657 for Tendermint RPC
 + 8545 for Json RPC
 + 9090 for gRPC
 + 26656 for peer discovery
- Node 1 (2nd validator) will NOT public any port, all endpoint will be adjusted to opens on localhost and almost port will be closed by default. Only open the following ports
 + Tendermint RPC
 + Peer discovery
 + pprof_laddr
- Same as node 1, the node 2 (3rd validator) will NOT public any port, all endpoint will be adjusted to opens on localhost and almost port will be closed by default. Only open the following ports
 + Tendermint RPC
 + Peer discovery
 + pprof_laddr

**NOTICE**
You have to add file following domain `evmos1.victortrusty.dev` to hosts file and resolve it to IP address of this machine (can not be 127.0.0.1) because it is being used for this node becomes seed node (check config.toml [p2p > seed])

#### Step 2: create validator
1. Copy the `bak_genesis.json` and `bak_config.toml` which was generated and backed up in the first node to current directory
2. Make sure the node 1 already started (`evmosd start --home ~/.evmosd-?`)
2. Execute the command
> $ ./create-validator.sh 2

or
> $ ./create-validator.sh 3

Want more validator? Just create more, no problem