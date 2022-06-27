### Decrease the minimum deposit amount for governance proposals and maximum deposit period
#### If successful, this parameter-change governance proposal that will change the minimum deposit from 64 EVMOS to 100000 aevmos and max deposit period changes from 14 days to 7 days
1. Remote into container and move to sample directory
> docker exec -it vtevmos20 bash

> cd /gov-sample-proposals/evmos/

2. Submit proposal
> evmosd tx gov submit-proposal param-change "./1-gov_min_deposit_change.json" --from val1 --node tcp://127.0.0.1:26657 --home /.evmosd20 --gas 300000

3. Vote
> docker exec -it vtevmos20 bash

> evmosd tx gov vote `[proposal id eg 1]` yes --gas auto --from val1 --home /.evmosd20

> docker exec -it vtevmos21 bash

> evmosd tx gov vote `[proposal id eg 1]` yes --gas auto --from val2 --home /.evmosd21

> docker exec -it vtevmos22 bash

> evmosd tx gov vote `[proposal id eg 1]` yes --gas auto --from val3 --home /.evmosd22

4. Result:
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