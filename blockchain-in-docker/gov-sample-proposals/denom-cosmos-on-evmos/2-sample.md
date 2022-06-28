### Register denom of ATOM (via IBC) on EVMOS chain (`ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2`)

1. Submit proposal
> docker exec -it vtevmos20 bash

> cd /gov-sample-proposals/denom-cosmos-on-evmos/

> evmosd tx gov submit-proposal param-change "./2-gov-register-coin.json" --from val1 --node tcp://127.0.0.1:26657 --home /.evmosd2 --gas 300000 --deposit 65000000000000000000aevmos