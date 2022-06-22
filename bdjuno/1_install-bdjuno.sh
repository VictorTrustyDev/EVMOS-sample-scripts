#!/bin/bash

command -v docker > /dev/null 2>&1 || { echo >&2 "docker is required"; exit 1; }
command -v psql > /dev/null 2>&1 || { echo >&2 "psql is required, you first need to install psql client. Hint: sudo apt install postgresql-client"; exit 1; }

source ../env.sh

CHAIN_NO=$1

if [ -f "./_config.sh" ]; then
    source "./_config.sh"
fi

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Creating bdjuno for $CHAIN_1_ID"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Creating bdjuno for $CHAIN_2_ID"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

PG_CON_NAME="bdjdb$CHAIN_NO"
PG_VOL_NAME="bdjdb$CHAIN_NO"
BDJUNO_SERVICE_NAME="bdjuno-svc$CHAIN_NO"

# Stop service if exists
[ $DISABLE_SYSTEMCTL -eq 0 ] && {
	echo "Stopping $BDJUNO_SERVICE_NAME service"; 
	sudo systemctl stop $BDJUNO_SERVICE_NAME > /dev/null 2>&1;
	sudo systemctl disable $BDJUNO_SERVICE_NAME > /dev/null 2>&1;
}

echo 'Remove existing docker container & volumes'
sleep 3s
docker rm -f $PG_CON_NAME
docker volume rm -f $PG_VOL_NAME

# Remake
echo "Remake database and expose port $PG_PORT"
docker run \
  --restart unless-stopped \
  --name $PG_CON_NAME \
  -d \
  -p $PG_PORT:5432 \
  -e POSTGRES_PASSWORD=$BD_CFG_PG_USR_PASS \
  -v $PG_VOL_NAME:/data/db \
  postgres:12.5
[ $? -eq 0 ] || { echo "ERR: Failed to create a PostgreSQL container"; }

echo 'Waiting DB up'
sleep 3s

echo "- Creating database $BD_CFG_DB"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "CREATE DATABASE $BD_CFG_DB;"
[ $? -eq 0 ] || { echo "ERR: Operation failed!"; }
echo "- Creating user $BD_CFG_USER"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "CREATE USER $BD_CFG_USER WITH ENCRYPTED PASSWORD '$BD_CFG_PASS';"
[ $? -eq 0 ] || { echo "ERR: Operation failed!"; }
echo "- Grant all privileges on db $BD_CFG_DB to user $BD_CFG_USER"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $BD_CFG_DB TO $BD_CFG_USER;"
[ $? -eq 0 ] || { echo "ERR: Operation failed!"; }

# Check bdjuno source
if [ -d "./$BDJ_SOURCE_DIR" ]; then
    echo "bdjuno repo was downloaded"
else
    echo "Downloading bdjuno source code from branch $BDJ_BRANCH"
    git clone https://github.com/forbole/bdjuno.git --branch $BDJ_BRANCH --single-branch "$BDJ_SOURCE_DIR"

    if [ $? -ne 0 ]; then
        echo "Git clone bdjuno branch $BDJ_BRANCH failed"
        exit 1
    fi
fi

SCHEMA_DIR="./$BDJ_SOURCE_DIR/database/schema"

if [ ! -d "$SCHEMA_DIR" ]; then
  echo "ERR: Schema dir $SCHEMA_DIR could not be found"
  exit 1
fi

CUR_DIR=$(pwd)
cd "$SCHEMA_DIR"
echo "- Run sql files"
ls -1 | while read line ; do PGPASSWORD=$BD_CFG_PASS psql -h 127.0.0.1 -p $PG_PORT -d $BD_CFG_DB -U $BD_CFG_USER -f $line ; done

cd "$CUR_DIR"
cd "./$BDJ_SOURCE_DIR"
echo
echo 'Compiling bdjuno'
make install

export BDJ_HOME=$(pwd)"/.bdjuno$CHAIN_NO"
echo "Init bdjuno"
rm -rf "$BDJ_HOME"
$BDJ_BINARY init --home "$BDJ_HOME"

echo 'Config bdjuno'
CONFIG_YAML="$BDJ_HOME/config.yaml"
sed -i "s/bech32_prefix: cosmos/bech32_prefix: $ACCOUNT_PREFIX/g" $CONFIG_YAML
sed -i "s,http://localhost:26657,http://$RPC_ADDR,g" $CONFIG_YAML
sed -i "s/address: localhost:9090/address: $GRPC_ADDR/g" $CONFIG_YAML
sed -i "s/name: database-name/name: $BD_CFG_DB/g" $CONFIG_YAML
#sed -i "s/host: localhost/host: $PG_HOST/g" $CONFIG_YAML
sed -i "s/user: user/user: $BD_CFG_USER/g" $CONFIG_YAML
sed -i "s/password: password/password: $BD_CFG_PASS/g" $CONFIG_YAML

echo "Step 1 done!"
echo "- Postgres SQL db was exposed to port $PG_PORT"
echo "- bdjuno home: $BDJ_HOME"
echo "Now you need to:"
echo "- copy genesis.json of the chain and put it into $BDJ_HOME folder (expect file $BDJ_HOME/genesis.json)"
echo "- update file $BDJ_HOME/config.yaml (refer to or copy from sample.config.yaml)"

echo "After that you can move to step 2 (run ./2_install-bdjuno.sh)"
