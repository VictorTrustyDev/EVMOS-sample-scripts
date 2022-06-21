### This helps you create 2 EVMOS networks ([v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)) with 3 validators and run with docker compose

#### Create first network

> $ ./1_prepare.sh 1

> $ ./1_prepare.sh 1

**NOTICE**
You have to add file following domain `evmos1.victortrusty.dev` to hosts file and resolve it to IP address of this machine (or 127.0.0.1) because it is being used for this node becomes seed node (check `config.toml` [p2p > seed])

#### Step 2: create validator
1. Copy the `bak_genesis.json` and `bak_config.toml` which was generated and backed up in the first node to current directory
2. Make sure the node 0 already started (`evmosd start --home ~/.evmosd10`)
2. Execute the command
> $ ./create-validator.sh 2 (or 3)

The new validator will be create based on above accounts with 3k coin staked

The opened ports depends on which network you created (view the list in the end of this page)

Want more validator? Just create more, no problem

### Network stats

| Network | Chain ID | RPC | Json RPC | REST | gRPC | P2P |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | evmos_9006-1 | 26657 | 8545 | 1317 | 9090 | 26656 |
| 2 | evmos_9007-1 | 36657 | 18545 | 11317 | 19090 | 36656 |

- Validators (same on both networks)
    + val1
        + 50m EVMOS
        + 7k coin staked
        + Addr: evmos1wuqvcpuunf7r5rg7xutqddhw55grfzc75qejyq
        + Mnemonic: spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi
    + val2 (this account can be used to create next validator)
        + 50m EVMOS
        + 3k coin staked
        + Addr: evmos1zxgt4pwzzsv02z24g80lc5rhtsp0prw0c5tk3d
        + Mnemonic: width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle
    + val3 (this account can be used to create next validator)
        + 50m EVMOS
        + 3k coin staked
        + Addr: evmos1vcy9v4jp0sd4hysqqcuwleytxre3ms4ckzmdnz
        + Mnemonic: stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father