#!/bin/bash

command -v docker > /dev/null 2>&1 || { echo >&2 "docker is required"; exit 1; }
command -v psql > /dev/null 2>&1 || { echo >&2 "psql is required, you first need to install psql client. Hint: sudo apt install postgresql-client"; exit 1; }

source ../env.sh

CHAIN_NO=$1

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

if [ -f "./_config.sh" ]; then
    source "./_config.sh"
else
    echo "ERR: Wrong working directory"
    echo "ERR: Scripts must be executed within [big-dipper-as-block-explorer] directory"
    exit 1
fi

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Chain 1"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Chain 2"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

PG_CON_NAME="bdjdb$CHAIN_NO"
PG_VOL_NAME="bdjdb$CHAIN_NO"

# Stop service if exists
[ $DISABLE_SYSTEMCTL -eq 0 ] && {
	echo "Stopping $BD_SERVICE_NAME service"; 
	sudo systemctl stop $BD_SERVICE_NAME > /dev/null 2>&1;
	sudo systemctl disable $BD_SERVICE_NAME > /dev/null 2>&1;
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

echo "- Creating database $BD_PG_DB"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "CREATE DATABASE $BD_PG_DB;"
[ $? -eq 0 ] || { echo "ERR: Operation failed!"; }
echo "- Creating user $BD_PG_USER"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "CREATE USER $BD_PG_USER WITH ENCRYPTED PASSWORD '$BD_PG_PASS';"
[ $? -eq 0 ] || { echo "ERR: Operation failed!"; }
echo "- Grant all privileges on db $BD_PG_DB to user $BD_PG_USER"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $BD_PG_DB TO $BD_PG_USER;"
[ $? -eq 0 ] || { echo "ERR: Operation failed!"; }

# Check bdjuno source
if [ -d "./$BD_SOURCE_DIR" ]; then
    echo "bdjuno repo was downloaded"
else
    echo "Downloading bdjuno source code from branch $BD_BRANCH"
    git clone "$BD_GIT_REPO" --branch "$BD_BRANCH" --single-branch "$BD_SOURCE_DIR"

    if [ $? -ne 0 ]; then
        echo "Git clone bdjuno branch $BD_BRANCH failed"
        exit 1
    fi
fi

SCHEMA_DIR="./$BD_SOURCE_DIR/database/schema"

if [ ! -d "$SCHEMA_DIR" ]; then
  echo "ERR: Schema dir $SCHEMA_DIR could not be found"
  exit 1
fi

CUR_DIR=$(pwd)
cd "$SCHEMA_DIR"
echo "- Run sql files"
ls -1 | while read line ; do PGPASSWORD=$BD_PG_PASS psql -h 127.0.0.1 -p $PG_PORT -d $BD_PG_DB -U $BD_PG_USER -f $line ; done

cd "$CUR_DIR"
cd "./$BD_SOURCE_DIR"
echo
echo 'Compiling bdjuno'
make install
[ $? -ne 0 ] && { echo "ERR: Failed to compile"; exit 1; }
echo "Rename $BD_BINARY_ORIGIN into $BD_BINARY"
mv "$BD_BINARY_ORIGIN" "$BD_BINARY"
cd "$CUR_DIR"

echo "Init bdjuno"
rm -rf "$BD_HOME"
$BD_BINARY init --home "$BD_HOME"

echo 'Config bdjuno'
CONFIG_YAML="$BD_HOME/config.yaml"
cp "./template.config.yaml" "$CONFIG_YAML"

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/p_bech32_prefix/$ACCOUNT_PREFIX/g" "$CONFIG_YAML"
    sed -i '' "s,p_rpc_addr,$RPC_ADDR,g" "$CONFIG_YAML"
    sed -i '' "s,p_grpc_addr,$GRPC_ADDR,g" "$CONFIG_YAML"
    sed -i '' "s/p_db_name/$BD_PG_DB/g" "$CONFIG_YAML"
    sed -i '' "s/p_db_user/$BD_PG_USER/g" "$CONFIG_YAML"
    sed -i '' "s/p_db_port/$PG_PORT/g" "$CONFIG_YAML"
    sed -i '' "s/p_db_pass/$BD_CFG_PG_USR_PASS/g" "$CONFIG_YAML"
    sed -i '' "s/p_token_denom/$DENOM_SYMBOL/g" "$CONFIG_YAML"
    sed -i '' "s/p_token_min_denom/$MIN_DENOM_SYMBOL/g" "$CONFIG_YAML"
    sed -i '' "s/p_denom_exponent/$DENOM_EXPONENT/g" "$CONFIG_YAML"
    sed -i '' "s/p_action_port/$BD_HASURA_ACTIONBASE_PORT/g" "$CONFIG_YAML"
else
    sed -i "s/p_bech32_prefix/$ACCOUNT_PREFIX/g" "$CONFIG_YAML"
    sed -i "s,p_rpc_addr,$RPC_ADDR,g" "$CONFIG_YAML"
    sed -i "s,p_grpc_addr,$GRPC_ADDR,g" "$CONFIG_YAML"
    sed -i "s/p_db_name/$BD_PG_DB/g" "$CONFIG_YAML"
    sed -i "s/p_db_user/$BD_PG_USER/g" "$CONFIG_YAML"
    sed -i "s/p_db_port/$PG_PORT/g" "$CONFIG_YAML"
    sed -i "s/p_db_pass/$BD_CFG_PG_USR_PASS/g" "$CONFIG_YAML"
    sed -i "s/p_token_denom/$DENOM_SYMBOL/g" "$CONFIG_YAML"
    sed -i "s/p_token_min_denom/$MIN_DENOM_SYMBOL/g" "$CONFIG_YAML"
    sed -i "s/p_denom_exponent/$DENOM_EXPONENT/g" "$CONFIG_YAML"
    sed -i "s/p_action_port/$BD_HASURA_ACTIONBASE_PORT/g" "$CONFIG_YAML"
fi

echo "Step 1 done!"
echo "- Postgres SQL db was exposed to port $PG_PORT"
echo "- bdjuno home: $BD_HOME"
echo "- hasura action base was exposed to port : $BD_HASURA_ACTIONBASE_PORT"
echo "Now you need to:"
echo "- copy genesis.json of the chain and put it into $BD_HOME folder (expect file $BD_HOME/genesis.json)"
echo '// TODO: try to add mint module to config.yaml'

echo "After that you can move to step 2 (run ./2_install-bdjuno.sh)"