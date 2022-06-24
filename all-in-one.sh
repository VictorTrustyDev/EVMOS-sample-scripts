#!/bin/bash

if [ ! -f "./env.sh" ]; then
    echo "Wrong working directory"
    exit 1
fi

command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/ (Hint: sudo apt install jq -y)"; exit 1; }
command -v yq > /dev/null 2>&1 || { echo >&2 "yq not installed. More info: https://github.com/kislyuk/yq/ (Hint: sudo apt install python3-pip -y && pip3 install yq)"; exit 1; }
command -v tomlq > /dev/null 2>&1 || { echo >&2 "tomlq not installed, it is expected to be delivered within yq package"; exit 1; }
command -v bc > /dev/null 2>&1 || { echo >&2 "bc command could not be found"; exit 1; }
command -v make > /dev/null 2>&1 || { echo >&2 "make command could not be found"; exit 1; }
command -v go > /dev/null 2>&1 || { echo >&2 "go was not installed. More info: https://go.dev/doc/install"; exit 1; }
command -v docker > /dev/null 2>&1 || { echo >&2 "docker is required"; exit 1; }
command -v 'docker-compose' > /dev/null 2>&1 || { echo >&2 "docker-compose is required"; exit 1; }
command -v cargo > /dev/null 2>&1 || { echo >&2 "Rust & Cargo was not installed. More info: https://www.rust-lang.org/tools/install . Hint: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"; exit 1; }
command -v psql > /dev/null 2>&1 || { echo >&2 "psql is required, you first need to install psql client. Hint: sudo apt install postgresql-client"; exit 1; }
command -v npm > /dev/null 2>&1 || { echo >&2 "npm is required"; exit 1; }

echo "Run everything requires:"
echo "- Your machine must have at least 4 Cores and 16 Gb of RAM"
echo "- Required ports are available"
echo "- OS supports systemd"
echo "Running this script is NOT recommended, you better run the scripts separately by yourself to deeply understand"
read -p "Are you sure want to run this? (Y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    command -v systemctl > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "`systemd` is required!!! You better prepare an Ubuntu machine and try this later.."
        exit 1
    fi
    echo " ! Good, let's go"
else
    echo "Give up!"
    exit 0
fi

export FORCE_EXTRA_FUNC=1 # Auto create services and start them (sudo systemctl enable * & sudo systemctl start *)
export HERMES_NO_CONFIRM_BALANCE=1

AIO_CUR_DIR=$(pwd)
AIO_DIR_BD="./big-dipper-as-block-explorer"
AIO_DIR_HERMES="./hermes-as-ibc-relayer"
AIO_DIR_EVMOS="./evmos-on-docker"

echo "[Clean up previous setup]"

echo "> [Big Dipper]"
cd "$AIO_DIR_BD"
./cleanup.sh
cd "$AIO_CUR_DIR"

echo "> [Hermes]"
cd "$AIO_DIR_HERMES"
./cleanup.sh
cd "$AIO_CUR_DIR"

echo "> [EVMOS]"
cd "$AIO_DIR_EVMOS"
./cleanup.sh
cd "$AIO_CUR_DIR"

echo "[Setup]"
cd "$AIO_DIR_EVMOS"
echo "> [EVMOS network 1]"
./1_prepare-genesis.sh 1
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (genesis)"; }
sleep 2s
./2_build-docker-image.sh 1
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (build docker image)"; }
sleep 2s
docker-compose -f network1.yml up -d
echo "> [EVMOS network 2]"
./1_prepare-genesis.sh 2
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (genesis)"; }
sleep 2s
./2_build-docker-image.sh 2
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (build docker image)"; }
sleep 2s
docker-compose -f network2.yml up -d
sleep 5s

cd "$AIO_CUR_DIR"
cd "$AIO_DIR_HERMES"
if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi
echo "> [Load up token for IBC account on network 1]"
docker exec -it vtevmos11 bash -c "evmosd tx bank send $VAL_2_KEY_NAME $REL_1_ADDR $(bc <<< "$HERMES_RESERVED_FEE * (10^$HERMES_CFG_CHAIN_1_DENOM_EXPONENT)")$HERMES_CFG_CHAIN_1_GAS_PRICE_DENOM_SYMBOL --home /.evmosd11 --yes"
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed"; }
echo "> [Load up token for IBC account on network 2]"
docker exec -it vtevmos21 bash -c "evmosd tx bank send $VAL_2_KEY_NAME $REL_2_ADDR $(bc <<< "$HERMES_RESERVED_FEE * (10^$HERMES_CFG_CHAIN_2_DENOM_EXPONENT)")$HERMES_CFG_CHAIN_2_GAS_PRICE_DENOM_SYMBOL --home /.evmosd21 --yes"
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed"; }

echo "> [Hermes]"
./create-hermes.sh
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed"; }
cd "$AIO_CUR_DIR"

cd "$AIO_DIR_BD"
echo "> [bdjuno for network 1]"
./1_install-bdjuno.sh 1
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (step 1 bdjuno)"; }
./2_install-bdjuno.sh 1
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (step 2 bdjuno)"; }
./3_install-hasura.sh 1
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (hasura)"; }
echo "> [bdjuno for network 2]"
./1_install-bdjuno.sh 2
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (step 1 bdjuno)"; }
./2_install-bdjuno.sh 2
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (step 2 bdjuno)"; }
./3_install-hasura.sh 2
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed (hasura)"; }
echo "> [Big Dipper UI for network 1]"
./4_install-front-end.sh 1
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed"; }
echo "> [Big Dipper UI for network 2]"
./4_install-front-end.sh 2
[ $? -eq 0 ] || { echo "ERR AIO: Operation failed"; }

echo "Finished"