### This helps you create 2 EVMOS chains ([v5.0.0](https://github.com/evmos/evmos/tree/v5.0.0)) with 3 validators on each chain and run with docker compose

### I. Create first chain

> $ ./1_prepare-genesis.sh 1

> $ ./2_build-docker-image.sh 1

> $ docker-compose -f network1.yml up -d

To turn it off
> $ docker-compose -f network1.yml down

### II. Create second chain

> $ ./1_prepare-genesis.sh 2

> $ ./2_build-docker-image.sh 2

> $ docker-compose -f network2.yml up -d

To turn it off
> $ docker-compose -f network2.yml down

Now you can [follow this sample](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/tree/main/hermes-as-ibc-relayer) to create an IBC relayer to connect them

### III. Network stats

| Network | Chain ID | RPC | Json RPC | REST | gRPC | P2P |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | evmos_9006-1 | 26657 | 8545 | 1317 | 9090 | 26656 |
| 2 | evmos_9007-1 | 36657 | 18545 | 11317 | 19090 | 36656 |

- Validators (same on both chains)
    + evmosvaloper1wuqvcpuunf7r5rg7xutqddhw55grfzc7ewkz9a
        + 50m EVMOS
        + 7k coin staked
        + EVMOS wallet addr: evmos1wuqvcpuunf7r5rg7xutqddhw55grfzc75qejyq
        + Private key: FC3F58B007A017166DE5A340C7A2641EB37CF37081D6F9013636CEBFBAF7B1FE
        + Mnemonic: spoil senior door access upset floor decorate shield high punch senior tape pigeon base slogan height clever buffalo cat report poem weapon labor satoshi
        + Key name: val1
    + evmosvaloper1zxgt4pwzzsv02z24g80lc5rhtsp0prw046yxss
        + 50m EVMOS
        + 3k coin staked
        + EVMOS wallet addr: evmos1zxgt4pwzzsv02z24g80lc5rhtsp0prw0c5tk3d
        + Private key: 0172DC491B5ACD04DD378D3FD8FD9F41A0D701E070941474FADECD72E1E085B9
        + Mnemonic: width produce brush hour horse retreat play flag fresh broken measure culture scare broken erupt pilot buzz embody depend topic behind rigid fan battle
        + Key name: val2
    + evmosvaloper1vcy9v4jp0sd4hysqqcuwleytxre3ms4cmv5ajl
        + 50m EVMOS
        + 3k coin staked
        + EVMOS wallet addr: evmos1vcy9v4jp0sd4hysqqcuwleytxre3ms4ckzmdnz
        + Private key: E0D83C6054597638469CC91A46F14B7F62705297912524059629E4674302928F
        + Mnemonic: stage grid emotion thumb safe myth chair dizzy beyond casual select polar hover retire master neglect shift zero trigger section token replace truly father
        + Key name: val3

### IV. Customization
You can custom your chain just by editting keys in the [env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh) file

Here are some of them:

| Key | Default value | Explain |
| --- | --- | --- |
| `CHAIN_1_GIT_REPO` | https://github.com/evmos/evmos.git | Git repo to be used to build chain 1 |
| `CHAIN_1_GIT_REPO_BRANCH` | v5.0.0 | Git branch to be used to build chain 1 |
| `CHAIN_1_ID` | evmos_9006-1 | Chain id of chain 1 |
| `CHAIN_1_TYPE` | evmos | Chain type of chain 1 |
| `CHAIN_1_COINTYPE` | 60 | [HD key derivation path](https://docs.evmos.org/users/technical_concepts/accounts.html) for chain 1's accounts |
| `CHAIN_2_GIT_REPO` | https://github.com/evmos/evmos.git | Git repo to be used to build chain 2 |
| `CHAIN_2_GIT_REPO_BRANCH` | v5.0.0 | Git branch to be used to build chain 2 |
| `CHAIN_2_ID` | evmos_9007-1 | Chain id of chain 2 |
| `CHAIN_2_TYPE` | evmos | Chain type of chain 2 |
| `CHAIN_2_COINTYPE` | 60 | [HD key derivation path](https://docs.evmos.org/users/technical_concepts/accounts.html) for chain 2's accounts |

Performance: 2 chains created by this sample can run in parallel smoothly in a 4 Core 4 Gb RAM machine

This sample is using keyring-backend is `test`, you may need to change to `file` ([env.sh](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/blob/main/env.sh)) to secure your test env if needed