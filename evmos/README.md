### This sample will create a simple EVMOS network ([v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)) with 1 validator pre-defined, script supports add 2 more validators

#### Step 1: create an EVMOS network
> $ ./create-network-on-machine.sh 1

[You can view stats of network 1 here](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/evmos/network1.md)

or 
> $ ./create-network-on-machine.sh 2

Will create network 2 with stats [as defined here](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/evmos/network2.md)

**NOTICE**
You have to add file following domain `evmos1.victortrusty.dev` to hosts file and resolve it to IP address of this machine (can not be 127.0.0.1) because it is being used for this node becomes seed node (check `config.toml` [p2p > seed])

#### Step 2: create validator
1. Copy the `bak_genesis.json` and `bak_config.toml` which was generated and backed up in the first node to current directory
2. Make sure the node 1 already started (`evmosd start --home ~/.evmosd-?`)
2. Execute the command
> $ ./create-validator.sh 2

or
> $ ./create-validator.sh 3

The opened ports depends on which network you created [1](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/evmos/network1.md) or [2](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/evmos/network2.md)

Want more validator? Just create more, no problem