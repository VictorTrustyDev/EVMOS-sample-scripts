### Register denom of ATOM (via IBC) on EVMOS chain (`ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2`)

#### Submit proposal
> docker exec -it vtevmos20 bash

> evmosd tx gov submit-proposal register-coin "/gov-sample-proposals/denom-cosmos-on-evmos/2-gov-register-coin.json" --from val1 --node tcp://127.0.0.1:26657 --home /.evmosd2 --gas auto --deposit 65000000000000000000aevmos --title "Register IBC denom for native staking and governance token of the Cosmos chain" --description "The native staking and governance token of the Cosmos chain"

#### Accept it
> evmosd tx gov vote 1 yes --gas auto --from val1 --home /.evmosd2 --yes

> evmosd tx gov vote 1 yes --gas auto --from val2 --home /.evmosd2 --yes

> evmosd tx gov vote 1 yes --gas auto --from val3 --home /.evmosd2 --yes