#!/bin/bash

# This script will setup
# - 2 chains
# - 1 Hermes as IBC relayer
# - 2 Big Dipper as Block Explorer
# In a single command!
# It is not recommended to use this script

if [ ! -f "./env.sh" ]; then
    echo >&2 "ERR: Wrong working directory"
    exit 1
fi

show_required_tools() {
    MSG="'$1' tool is required"
    echo >&2 "ERR: $MSG"
    echo >&2 "______"
    echo >&2 "The app requires following tools:"
    echo >&2 "- jq"
    echo >&2 " + https://stedolan.github.io/jq/download/"
    echo >&2 " + Hint: sudo apt install jq -y"
    echo >&2 "- yq & tomlq"
    echo >&2 " + https://github.com/kislyuk/yq/"
    echo >&2 " + Hint: sudo apt install python3-pip -y && pip3 install yq"
    echo >&2 "- go"
    echo >&2 " + https://go.dev/doc/install"
    echo >&2 "- docker & docker-compose"
    echo >&2 "- Rust & cargo"
    echo >&2 " + https://www.rust-lang.org/tools/install"
    echo >&2 " + Hint: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    echo >&2 "- psql (PostgreSQL client)"
    echo >&2 " + Hint: sudo apt install postgresql-client"
    echo >&2 "- npm"
    echo >&2 "- yarn"
    echo >&2 "- hasura-cli"
    echo >&2 " + https://hasura.io/docs/latest/graphql/core/hasura-cli/install-hasura-cli/"
    echo >&2 " + Hint: curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | bash"
    echo >&2 "______"
    echo >&2 "ERR: $MSG"
}

command -v jq > /dev/null 2>&1 || { show_required_tools 'jq'; exit 1; }
command -v yq > /dev/null 2>&1 || { show_required_tools 'yq'; exit 1; }
command -v tomlq > /dev/null 2>&1 || { show_required_tools 'tomlq'; exit 1; }
command -v bc > /dev/null 2>&1 || { show_required_tools 'bc'; exit 1; }
command -v make > /dev/null 2>&1 || { show_required_tools 'make'; exit 1; }
command -v go > /dev/null 2>&1 || { show_required_tools 'go'; exit 1; }
command -v docker > /dev/null 2>&1 || { show_required_tools 'docker'; exit 1; }
command -v 'docker-compose' > /dev/null 2>&1 || { show_required_tools 'docker-compose'; exit 1; }
command -v cargo > /dev/null 2>&1 || { show_required_tools 'cargo'; exit 1; }
command -v psql > /dev/null 2>&1 || { show_required_tools 'psql'; exit 1; }
command -v npm > /dev/null 2>&1 || { show_required_tools 'npm'; exit 1; }
command -v yarn > /dev/null 2>&1 || { show_required_tools 'yarn'; exit 1; }

source "./env.sh"
if [ -f "$BD_HASURA_BINARY" ]; then
    echo
elif [ command -v hasura > /dev/null 2>&1 ]; then
    echo
else
    show_required_tools 'hasura-cli'
    exit 1
fi
if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

echo "Run everything requires:"
echo "- Your machine should have 4 Cores and 16 Gb of RAM (usage: ~20%-80% per core and 50% ram)"
echo "- Required ports are available"
echo "- OS supports systemd"
echo "Running this script is NOT recommended, you better run the scripts separately by yourself to deeply understand"
read -p "ARE YOU SURE still want to run this script? (Y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    command -v systemctl > /dev/null 2>&1
    if [ $? -ne 0 ] || [ ! -d "/etc/systemd/system" ] ; then
        echo >&2 "`systemd` is required!!! You better prepare an Ubuntu machine and try this later.."
        exit 1
    fi
    echo " ! OK, let's go"
else
    echo "Give up!"
    exit 0
fi

export FORCE_EXTRA_FUNC=1 # Auto create services and start them (sudo systemctl enable * & sudo systemctl start *)
export HERMES_NO_CONFIRM_BALANCE=1

AIO_CUR_DIR=$(pwd)
AIO_DIR_BD="./big-dipper-as-block-explorer"
AIO_DIR_HERMES="./hermes-as-ibc-relayer"
AIO_DIR_CHAIN="./blockchain-in-docker"

GAS_PRICE_1="$(bc <<< "20 * (10^$CHAIN_1_GAS_DENOM_EXPONENT)")$CHAIN_1_MIN_DENOM_SYMBOL"
GAS_PRICE_2="$(bc <<< "20 * (10^$CHAIN_2_GAS_DENOM_EXPONENT)")$CHAIN_2_MIN_DENOM_SYMBOL"

echo "[Clean up previous setup]"

echo "> [Big Dipper]"
cd "$AIO_DIR_BD"
./cleanup.sh
cd "$AIO_CUR_DIR"

echo "> [Hermes]"
cd "$AIO_DIR_HERMES"
./cleanup.sh
cd "$AIO_CUR_DIR"

echo "> [Chains]"
cd "$AIO_DIR_CHAIN"
./cleanup.sh
cd "$AIO_CUR_DIR"

echo "[Setup]"
cd "$AIO_DIR_CHAIN"
echo "> [Chain 1]"
./1_prepare-genesis.sh 1
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (genesis)"; exit 1; }
sleep 2s
./2_build-docker-image.sh 1
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (build docker image)"; exit 1; }
sleep 2s
docker-compose -f network1.yml up -d
echo "> [Chain 2]"
./1_prepare-genesis.sh 2
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (genesis)"; exit 1; }
sleep 2s
./2_build-docker-image.sh 2
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (build docker image)"; exit 1; }
sleep 2s
docker-compose -f network2.yml up -d
sleep 5s

cd "$AIO_CUR_DIR"
cd "$AIO_DIR_HERMES"
if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi
echo "> [Load up token for IBC account on chain 1]"
echo "Keyring: $KEYRING"
if [ "$KEYRING" = "test" ]; then
    docker exec -it vtevmos11 bash -c "$CHAIN_1_DAEMON_BINARY_NAME tx bank send $VAL_2_KEY_NAME $REL_1_ADDR $(bc <<< "$HERMES_RESERVED_FEE * (10^$HERMES_CFG_CHAIN_1_DENOM_EXPONENT)")$HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL --gas-prices $GAS_PRICE_1 --home /.evmosd1 --node 'tcp://127.0.0.1:26657' --yes"
else
    docker exec -it vtevmos11 bash -c "echo '$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD' | $CHAIN_1_DAEMON_BINARY_NAME tx bank send $VAL_2_KEY_NAME $REL_1_ADDR $(bc <<< "$HERMES_RESERVED_FEE * (10^$HERMES_CFG_CHAIN_1_DENOM_EXPONENT)")$HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL --gas-prices $GAS_PRICE_1 --home /.evmosd1 --node 'tcp://127.0.0.1:26657' --yes"
fi
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed"; exit 1; }
echo "> [Load up token for IBC account on chain 2]"
if [ "$KEYRING" = "test" ]; then
    docker exec -it vtevmos21 bash -c "$CHAIN_2_DAEMON_BINARY_NAME tx bank send $VAL_2_KEY_NAME $REL_2_ADDR $(bc <<< "$HERMES_RESERVED_FEE * (10^$HERMES_CFG_CHAIN_2_DENOM_EXPONENT)")$HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL --gas-prices $GAS_PRICE_2 --home /.evmosd2 --node 'tcp://127.0.0.1:26657' --yes"
else
    docker exec -it vtevmos21 bash -c "echo '$VAL_KEYRING_FILE_ENCRYPTION_PASSWORD' | $CHAIN_2_DAEMON_BINARY_NAME tx bank send $VAL_2_KEY_NAME $REL_2_ADDR $(bc <<< "$HERMES_RESERVED_FEE * (10^$HERMES_CFG_CHAIN_2_DENOM_EXPONENT)")$HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL --gas-prices $GAS_PRICE_2 --home /.evmosd2 --node 'tcp://127.0.0.1:26657' --yes"
fi
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed"; exit 1; }

echo "> [Hermes as IBC relayer]"
./create-relayer.sh
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed"; exit 1; }
cd "$AIO_CUR_DIR"

cd "$AIO_DIR_BD"
echo "> [bdjuno for chain 1]"
./1_install-bdjuno.sh 1
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (step 1 bdjuno)"; exit 1; }
./2_install-bdjuno.sh 1
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (step 2 bdjuno)"; exit 1; }
./3_install-hasura.sh 1
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (hasura)"; exit 1; }
echo "> [bdjuno for chain 2]"
./1_install-bdjuno.sh 2
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (step 1 bdjuno)"; exit 1; }
./2_install-bdjuno.sh 2
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (step 2 bdjuno)"; exit 1; }
./3_install-hasura.sh 2
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed (hasura)"; exit 1; }
echo "> [Big Dipper UI for chain 1]"
./4_install-front-end.sh 1
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed"; exit 1; }
echo "> [Big Dipper UI for chain 2]"
./4_install-front-end.sh 2
[ $? -eq 0 ] || { echo >&2 "ERR AIO: Operation failed"; exit 1; }

echo "Finished"
echo "Alright, all the services are Expected to be started, no need to do anything else"
echo "To make sure everything working well, you need to"
echo "1. Check 3 validator containers & make sure they are proceducing block"
echo "2. Make sure bdjuno & hasura services are ok"
echo "3. Go to block explorer UI and check things there"
echo "4. Check Hermes is working well"
echo "5. Make sure the service files at '/etc/systemd/system/*.service' has correct working directort and execution path (in case you changed any repo/branch)"
