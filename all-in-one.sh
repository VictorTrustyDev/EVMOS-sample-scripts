#!/bin/bash

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
read -p "Are you sure? (Y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo " ! Good, let's go"
else
    echo "Give up!"
    exit 0
fi

