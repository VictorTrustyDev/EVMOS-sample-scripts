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
    echo "ERR: Scripts must be executed within [bdjuno] directory"
    exit 1
fi

# Validate input
if [ "$CHAIN_NO" = "1" ]; then
    echo "Network 1"
elif [ "$CHAIN_NO" = "2" ]; then
    echo "Network 2"
else
    echo 'Missing or incorrect chain no as first argument, valid input is 1 or 2'
    echo 'For example:'
    echo " $0 1"
    echo " or: $0 2"
    exit 1
fi

if [ -f "$BD_HASURA_BINARY" ]; then
    echo "Hasura binary exists"
elif [ command -v hasura > /dev/null 2>&1 ]; then
    export BD_HASURA_BINARY="hasura"
else
    echo "hasura-cli is required, more info: https://hasura.io/docs/latest/graphql/core/hasura-cli/install-hasura-cli/ . Hint: curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash"
    exit 1
fi

BD_HASURA_CON_NAME="bdjhasura$CHAIN_NO"

echo 'Remove existing containers'
docker rm -f $BD_HASURA_CON_NAME
sleep 1s

echo 'Preparing DB'
echo 'Dropping old data if exists'
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "DROP DATABASE $BD_PG_HASURA_META_DB;"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "DROP DATABASE $BD_PG_HASURA_DB;"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "REASSIGN OWNED BY $BD_PG_HASURA_USER TO postgres;"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "DROP OWNED BY $BD_PG_HASURA_USER;"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "DROP USER $BD_PG_HASURA_USER;"

echo 'Create new DB and user'
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "CREATE DATABASE $BD_PG_HASURA_META_DB;"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "CREATE DATABASE $BD_PG_HASURA_DB;"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "CREATE USER $BD_PG_HASURA_USER WITH ENCRYPTED PASSWORD '$BD_PG_HASURA_PASS';"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $BD_PG_HASURA_META_DB TO $BD_PG_HASURA_USER;"
PGPASSWORD=$BD_CFG_PG_USR_PASS psql -h 127.0.0.1 -p $PG_PORT -d postgres -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $BD_PG_HASURA_DB TO $BD_PG_HASURA_USER;"

echo 'Create hasura container'
docker run \
  --restart unless-stopped \
  --name $BD_HASURA_CON_NAME \
  -d \
  -p $BD_HASURA_PORT:8080 \
  -e "HASURA_GRAPHQL_METADATA_DATABASE_URL=postgres://postgres:$BD_CFG_PG_USR_PASS@172.17.0.1:$PG_PORT/$BD_PG_HASURA_META_DB" \
  -e "HASURA_GRAPHQL_DATABASE_URL=postgres://$BD_PG_HASURA_USER:$BD_PG_HASURA_PASS@172.17.0.1:$PG_PORT/$BD_PG_DB" \
  -e "PG_DATABASE_URL=postgres://$BD_PG_HASURA_USER:$BD_PG_HASURA_PASS@172.17.0.1:$PG_PORT/$BD_PG_HASURA_DB" \
  -e HASURA_GRAPHQL_ENABLE_CONSOLE=true \
  -e HASURA_GRAPHQL_DEV_MODE=true \
  -e HASURA_GRAPHQL_ENABLED_LOG_TYPES="startup, http-log, webhook-log, websocket-log, query-log" \
  -e HASURA_GRAPHQL_UNAUTHORIZED_ROLE="anonymous" \
  -e "HASURA_GRAPHQL_ADMIN_SECRET=$BD_HASURA_SECRET" \
  -e ACTION_BASE_URL="http://172.17.0.1:$BD_HASURA_ACTIONBASE_PORT" \
  hasura/graphql-engine:v2.7.0

echo 'Wait hasura up'
sleep 3s

echo 'Applying Hasura metadata'

cd "$BD_SOURCE_DIR/hasura/"

$BD_HASURA_BINARY metadata apply --endpoint http://localhost:$BD_HASURA_PORT --admin-secret $BD_HASURA_SECRET

echo "Done, run the following command to test"
echo "curl http://localhost:$BD_HASURA_ACTIONBASE_PORT/account_balance --data '{ \"input\": { \"address\": \"evmos1wuqvcpuunf7r5rg7xutqddhw55grfzc75qejyq\"} }'"
