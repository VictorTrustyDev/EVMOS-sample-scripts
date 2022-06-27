### Decrease the minimum deposit amount for governance proposals and maximum deposit period
#### If successful, this parameter-change governance proposal that will change the minimum deposit from 64 EVMOS to 100000 aevmos and max deposit period changes from 14 days to 7 days
1. Remote into container and move to sample directory
> docker exec -it vtevmos20 bash

> cd /gov-sample-proposals/evmos/

2. Submit proposal
> evmosd tx gov submit-proposal param-change "./1-gov_min_deposit_change.json" --from val1 --node tcp://127.0.0.1:26657 --home /.evmosd20 --gas 300000