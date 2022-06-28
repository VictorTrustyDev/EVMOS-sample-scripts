### Decrease the minimum deposit amount for governance proposals and maximum deposit period
#### If successful, this parameter-change governance proposal that will change the minimum deposit from 64 EVMOS to 100000 aevmos and max deposit period changes from 14 days to 7 days
1. Submit proposal
> docker exec -it vtevmos20 bash

> cd /gov-sample-proposals/evmos/

> evmosd tx gov submit-proposal param-change "./1-gov_min_deposit_change.json" --from val1 --node tcp://127.0.0.1:26657 --home /.evmosd2 --gas 300000

You can check the proposal via commands or [web UI like big dipper](https://github.com/VictorTrustyDev/EVMOS-sample-scripts/tree/main/big-dipper-as-block-explorer)

2. Vote
> docker exec -it vtevmos20 bash

> evmosd tx gov vote `[proposal id eg 1]` yes --gas auto --from val1 --home /.evmosd2

> docker exec -it vtevmos21 bash

> evmosd tx gov vote `[proposal id eg 1]` yes --gas auto --from val2 --home /.evmosd2

> docker exec -it vtevmos22 bash

> evmosd tx gov vote `[proposal id eg 1]` yes --gas auto --from val3 --home /.evmosd2

Change will take effects after voting period ends (default 14 days)

_Trick: You can reduce voting period by override the `VOTING_PERIOID_IN_MINUTES` variable (eg: export VOTING_PERIOID_IN_MINUTES=15) so the voting periods only last for 15 minutes_

3. Result:
- Previous:
    > evmosd q params subspace gov depositparams --chain-id evmos_9007-1 --node tcp://127.0.0.1:36657

    > key: depositparams

    > subspace: gov
    
    > value: '{"min_deposit":[{"denom":"aevmos","amount":"64000000000000000000"}],"max_deposit_period":"172800000000000"}'

- Later:
    > evmosd q params subspace gov depositparams --chain-id evmos_9007-1 --node tcp://127.0.0.1:36657

    > key: depositparams

    > subspace: gov
    
    > value: '{"min_deposit":[{"denom":"aevmos","amount":"100000"}],"max_deposit_period":"604800000000000"}'