#!/bin/bash

command -v docker > /dev/null 2>&1 || { echo >&2 "docker is required"; exit 1; }

source ./env.sh

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

HASURA_CON_NAME=hasura-bdjuno

echo 'Remove existing containers'
docker rm -f $HASURA_CON_NAME
sleep 1s

echo 'Preparing DB'
echo 'Dropping old data if exists'
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "DROP DATABASE $PG_HASURA_META_DB;"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "DROP DATABASE $PG_HASURA_DB;"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "REASSIGN OWNED BY $PG_HASURA_USER TO postgres;"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "DROP OWNED BY $PG_HASURA_USER;"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "DROP USER $PG_HASURA_USER;"

echo 'Create new DB and user'
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "CREATE DATABASE $PG_HASURA_META_DB;"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "CREATE DATABASE $PG_HASURA_DB;"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "CREATE USER $PG_HASURA_USER WITH ENCRYPTED PASSWORD '$PG_HASURA_PASS';"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $PG_HASURA_META_DB TO $PG_HASURA_USER;"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $PG_HASURA_DB TO $PG_HASURA_USER;"

echo 'Create hasura container'
docker run \
  --restart unless-stopped \
  --name $HASURA_CON_NAME \
  -d \
  -p $HASURA_PORT:8080 \
  -e HASURA_GRAPHQL_METADATA_DATABASE_URL=postgres://postgres:$PG_PWD@$PG_INT_HOST:$PG_INT_PORT/$PG_HASURA_META_DB \
  -e HASURA_GRAPHQL_DATABASE_URL=postgres://$PG_JUNO_USER:$PG_JUNO_PASS@$PG_INT_HOST:$PG_INT_PORT/$PG_JUNO_DB \
  -e PG_DATABASE_URL=postgres://$PG_HASURA_USER:$PG_HASURA_PASS@$PG_INT_HOST:$PG_INT_PORT/$PG_HASURA_DB \
  -e HASURA_GRAPHQL_ENABLE_CONSOLE=true \
  -e HASURA_GRAPHQL_DEV_MODE=true \
  -e HASURA_GRAPHQL_ENABLED_LOG_TYPES="startup, http-log, webhook-log, websocket-log, query-log" \
  -e HASURA_GRAPHQL_UNAUTHORIZED_ROLE="anonymous" \
  -e HASURA_GRAPHQL_ADMIN_SECRET=$HASURA_SECRET \
  -e ACTION_BASE_URL="http://172.17.0.1:$HASURA_ACTIONBASE_PORT" \
  hasura/graphql-engine:v2.7.0

echo 'Wait hasura up'
sleep 5s

echo 'Applying Hasura metadata'

cd hasura/

$HASURA_BINARY metadata apply --endpoint http://localhost:$HASURA_PORT --admin-secret $HASURA_SECRET

echo "Done, run the following command to test"
echo "curl http://localhost:$HASURA_ACTIONBASE_PORT/account_balance --data '{ \"input\": { \"address\": \"evmos1wuqvcpuunf7r5rg7xutqddhw55grfzc75qejyq\"} }'"
