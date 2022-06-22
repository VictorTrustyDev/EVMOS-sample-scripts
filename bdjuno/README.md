### 

### I. Prepare
- **IMPORTANT** Open file `env.sh`, locate the variables with prefix `BD_CFG_CHAIN_*` and updated based on your need

### II. Create the BDJUNO
#### A. Create network 1
##### 1. Create & setup PG database, init bdjuno home `.bdjuno1`, update `.bdjuno1/config.yaml` file
> $ ./1_install-bdjuno.sh 1

##### 2. Copy `genesis.json` file into bdjuno home at `.bdjuno1` & parse it
> $ ./2_install-bdjuno.sh 1

##### 3. Run `hasura` graphql service and expose port
> $ ./3_install-hasura.sh 1

#### B. Create network 2
##### 1. Create & setup PG database, init bdjuno home `.bdjuno2`, update `.bdjuno2/config.yaml` file
> $ ./1_install-bdjuno.sh 2

##### 2. Copy `genesis.json` file into bdjuno home at `.bdjuno2` & parse it
> $ ./2_install-bdjuno.sh 2

##### 3. Run `hasura` graphql service and expose port
> $ ./3_install-hasura.sh 2
