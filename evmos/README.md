### This sample will create a simple EVMOS network with 3 validators pre-defined

#### Step 1: grant executable permission for scripts
> $ chmod +x *.sh

#### Step 2: create network
> $ ./create-network-on-machine.sh 1

The network will have following stats:
TODO

In the end of this script, you will be asked if you want to create more validator
- No: the seeds info in config.toml will only contains one seed node with format <TENDERMINT_ID>@localhost:26656
- Yes: the seeds info in config.toml will contains one seed node with format <TENDERMINT_ID>@evmos1i.victortrusty.dev:26656, you will need to update your /etc/hosts to resolve this domain 'evmos1i.victortrusty.dev' into your machine's IP address

#### Step 3: create validator
> $ ./create-validator.sh 2

or
> $ ./create-validator.sh 3

Want more validator? Just create more, no problem