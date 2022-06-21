### This helps you create 2 EVMOS networks ([v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)) with 3 validators on each network and run with docker compose

### I. Create first network

> $ ./1_prepare-genesis.sh 1

> $ ./2_build-docker-image.sh 1

> $ docker-compose -f network1.yml up -d

To turn it off
> $ docker-compose -f network1.yml down

### II. Create second network

> $ ./1_prepare-genesis.sh 2

> $ ./2_build-docker-image.sh 2

> $ docker-compose -f network2.yml up -d

To turn it off
> $ docker-compose -f network2.yml down

Now you can create IBC relayer to connect them

### III. Network stats

| Network | Chain ID | RPC | Json RPC | REST | gRPC | P2P |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | evmos_9006-1 | 26657 | 8545 | 1317 | 9090 | 26656 |
| 2 | evmos_9007-1 | 36657 | 18545 | 11317 | 19090 | 36656 |

- Validators (same on both networks)
    + evmosvaloper1wuqvcpuunf7r5rg7xutqddhw55grfzc7ewkz9a
        + 50m EVMOS
        + 7k coin staked
        + Addr: evmos1wuqvcpuunf7r5rg7xutqddhw55grfzc75qejyq
        + Mnemonic: spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi
        + Key name: val1
    + evmosvaloper1zxgt4pwzzsv02z24g80lc5rhtsp0prw046yxss
        + 50m EVMOS
        + 3k coin staked
        + Addr: evmos1zxgt4pwzzsv02z24g80lc5rhtsp0prw0c5tk3d
        + Mnemonic: width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle
        + Key name: val2
    + evmosvaloper1vcy9v4jp0sd4hysqqcuwleytxre3ms4cmv5ajl
        + 50m EVMOS
        + 3k coin staked
        + Addr: evmos1vcy9v4jp0sd4hysqqcuwleytxre3ms4ckzmdnz
        + Mnemonic: stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father
        + Key name: val3

#### Wants to custom chain id, etc... Modify the [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh) file

Performance: 2 networks created by this sample can run in parallel smoothly in a 4 core 4 gb ram machine

This sample is using keyring `test`, you may need to change to `file` for secure your test env if needed