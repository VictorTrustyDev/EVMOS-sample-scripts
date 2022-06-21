### This sample will create a simple EVMOS network ([v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)) with 1 validator pre-defined, script supports add 2 more validators

#### Step 1: create an EVMOS network
> $ ./create-network-on-machine.sh 1

This will create a new EVMOS network 1 with:
- Chain ID evmos_9006-1 (or `evmos_9007-1` if `./create-network-on-machine.sh 2`)
- One validator (node 0)
- P2P Seeds: _tendermint-node-id_@evmos1.victortrusty.dev:26656 (or `evmos2.victortrusty.dev` if `./create-network-on-machine.sh 2`)
- RPC 26657, P2P 26656, JSON RPC 8545, REST 1317,...
- 3 accounts
    + val1 as validator
        + 50m EVMOS
        + 7k coin staked
        + Addr: evmos1wuqvcpuunf7r5rg7xutqddhw55grfzc75qejyq
        + Mnemonic: spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi
    + val2 (this account can be used to create next validator)
        + 50m EVMOS (0 staked)
        + Addr: evmos1zxgt4pwzzsv02z24g80lc5rhtsp0prw0c5tk3d
        + Mnemonic: width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle
    + val3 (this account can be used to create next validator)
        + 50m EVMOS (0 staked)
        + Addr: evmos1vcy9v4jp0sd4hysqqcuwleytxre3ms4ckzmdnz
        + Mnemonic: stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father        

**NOTICE**
You have to add file following domain `evmos1.victortrusty.dev` to hosts file and resolve it to IP address of this machine (can not be 127.0.0.1) because it is being used for this node becomes seed node (check `config.toml` [p2p > seed])

#### Step 2: create validator
1. Copy the `bak_genesis.json` and `bak_config.toml` which was generated and backed up in the first node to current directory
2. Make sure the node 1 already started (`evmosd start --home ~/.evmosd-?`)
2. Execute the command
> $ ./create-validator.sh 2 (or 3)

The opened ports depends on which network you created (view the list in the end of this page)

Want more validator? Just create more, no problem

### Network stats

- Chain ID:
    + Network 1: evmos_9006-1
    + Network 2: evmos_9007-1

- Home dir:
    + Network 1: ~/.evmos1*
    + Network 2: ~/.evmos2*

- Node 0 (1st/genesis validator)
    + Home dir: `~/.evmosd10` on network 1 or `~/.evmosd20` on network 2
    + Service file `/etc/systemd/system/evmosd10.service`
    + Expose almost it's port to the world

| Port | Name | State (default) | Interface | Original Port Number |
| --- | --- | --- | --- | --- |
| 1317 | REST API | Open | 0.0.0.0 | - |
| 26657 | Tendermint RPC | Open | 0.0.0.0 | - |
| 8545 | Json RPC | Open | 0.0.0.0 | - |
| 9090 | gRPC | Open | 0.0.0.0 | - |
| 26656 | Peer | Open | 0.0.0.0 | - |
| 26658 | Proxy App | Close | localhost | - |
| 6060 | pprof_laddr | Open | localhost | - |

- Node 1 (2nd validator)
    + Home dir: `~/.evmosd11` on network 1 or `~/.evmosd21` on network 2
    + Service file `/etc/systemd/system/evmosd11.service`
    + Will NOT public any port, all endpoint will be adjusted to opens on localhost and almost port will be closed by default

| Port | Name | State (default) | Interface | Original Port Number |
| --- | --- | --- | --- | --- |
| 26767 | Tendermint RPC | Open | localhost | 26657 |
| 26766 | Peer | Open | localhost | 26656 |
| 1427 | REST API | Close | localhost | 1317 |
| 8655 | Json RPC | Close | localhost | 8545 |
| 8656 | Websocket Json RPC | Close | localhost | 8546 |
| 9200 | gRPC | Close | localhost | 9090 |
| 9201 | Web gRPC | Close | localhost | 9091 |
| 26768 | Proxy App | Close | localhost | 26658 |
| 6170 | pprof_laddr | Open | localhost | 6060 |

- The node 2 (3rd validator)
    + Home dir: `~/.evmosd12` on network 1 or `~/.evmosd22` on network 2
    + Service file `/etc/systemd/system/evmosd12.service`
    + Same as node 1, this node will NOT public any port, all endpoint will be adjusted to opens on localhost and almost port will be closed by defaultthe following ports

| Port | Name | State (default) | Interface | Original Port Number |
| --- | --- | --- | --- | --- |
| 26777 | Tendermint RPC | Open | localhost | 26657 |
| 26776 | Peer | Open | localhost | 26656 |
| 1437 | REST API | Close | localhost | 1317 |
| 8665 | Json RPC | Close | localhost | 8545 |
| 8666 | Websocket Json RPC | Close | localhost | 8546 |
| 9210 | gRPC | Close | localhost | 9090 |
| 9211 | Web gRPC | Close | localhost | 9091 |
| 26778 | Proxy App | Close | localhost | 26658 |
| 6180 | pprof_laddr | Open | localhost | 6060 |