### This helps you create a IBC relayer service using Hermes ([v0.15.0](https://github.com/informalsystems/ibc-rs/tree/v0.15.0)) to transfer coins between 2 chains

### I. Prepare
- **IMPORTANT** Open file `env.sh`, locate the variables with prefix `HERMES_CFG_CHAIN_*` and updated based on your need
- Hermes require an account on each chain with some coins reserved for broadcast tx purpose
    + Account used by default:
        + evmos1metw56lk3k4vhkh0vzxlr8p4mzpjvttmagvekp (for both chains)
            + Seed: raw course slim hockey salt crawl sick safe december during armed fragile
    + You need to manually transfer some coins (EVMOS) to this address, so the relayer can use this account to broadcast some needed transactions
        > Sample command: `$ evmosd tx bank send val1 evmos1metw56lk3k4vhkh0vzxlr8p4mzpjvttmagvekp 100000000000000000000aevmos --node tcp://127.0.0.1:26657`

### II. Create the IBC relayer
> $ ./create-relayer.sh

You can check the IBC token hash created by the following command:
> $ evmosd q bank balances evmos1metw56lk3k4vhkh0vzxlr8p4mzpjvttmagvekp --node tcp://127.0.0.1:26657 | grep denom | grep ibc

Sample output:
> denom: ibc/0E8BF52B5A990E16C4AF2E5ED426503F3F0B12067FB2B4B660015A64CCE38EA0

_The coin on chain A (eg aevmos) represents as `ibc/0E8BF...38EA0` on chain B, this hash changes on different relayers_

### III. Attention
- The tendermint light client id, connection id and channel id will be appends to `.hermes/config.toml` file
- If you send your coin (EVMOS) to a chain using different relayers (thus different channel id), your token will represent as a different IBC/_hash_
- (One time only) Before you can transfer coin to another chain using IBC, you must use the relayer account to transfer in order to init an `IBC/_hash_` for the token. **This script already helps you with that**