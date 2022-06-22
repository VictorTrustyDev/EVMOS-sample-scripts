#!/bin/bash

command -v docker > /dev/null 2>&1 || { echo >&2 "docker is required"; exit 1; }

source ./env.sh

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

PG_CON_NAME=bdjuno-pg
PG_VOL_NAME=bdjuno-pg

echo 'Stopping service'
sudo systemctl stop bdjuno

echo 'Remove existing docker container & volumes'
sleep 3s
docker rm -f $PG_CON_NAME

docker volume rm -f $PG_VOL_NAME

docker run \
  --restart unless-stopped \
  --name $PG_CON_NAME \
  -d \
  -p $PG_PORT:5432 \
  -e POSTGRES_PASSWORD=$PG_PWD \
  -v $PG_VOL_NAME:/data/db \
  postgres:12.5

echo 'Waiting DB up'
sleep 5s

PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "CREATE DATABASE $PG_JUNO_DB;"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "CREATE USER $PG_JUNO_USER WITH ENCRYPTED PASSWORD '$PG_JUNO_PASS';"
PGPASSWORD=$PG_PWD psql -h $PG_HOST -d postgres -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE $PG_JUNO_DB TO $PG_JUNO_USER;"

cd ./database/schema

ls -1 | while read line ; do PGPASSWORD=$PG_JUNO_PASS psql -h $PG_HOST -d $PG_JUNO_DB -U $PG_JUNO_USER -f $line ; done

cd ../..
echo 'Compiling bdjuno'
make install

echo 'Init bdjuno'
rm -rf $BDJUNO_HOME
$BDJUNO_BINARY init

echo 'Config bdjuno'
sed -i "s/bech32_prefix: cosmos/bech32_prefix: $COIN_PREFIX/g" $BDJUNO_HOME/config.yaml
sed -i "s,http://localhost:26657,http://$CHAIN_URL_26657,g" $BDJUNO_HOME/config.yaml
sed -i "s/address: localhost:9090/address: $CHAIN_GRPC/g" $BDJUNO_HOME/config.yaml
sed -i "s/name: database-name/name: $PG_JUNO_DB/g" $BDJUNO_HOME/config.yaml
sed -i "s/host: localhost/host: $PG_HOST/g" $BDJUNO_HOME/config.yaml
sed -i "s/user: user/user: $PG_JUNO_USER/g" $BDJUNO_HOME/config.yaml
sed -i "s/password: password/password: $PG_JUNO_PASS/g" $BDJUNO_HOME/config.yaml

echo "Step 1 done! Now you need to:"
echo "- copy genesis.json of the chain and put it into $BDJUNO_HOME folder (expect file $BDJUNO_HOME/genesis.json)"
echo "- update file $BDJUNO_HOME/config.yaml (refer to or copy from sample.config.yaml)"

echo "After that you can move to step 2 (run ./2_install-bdjuno.sh)"
