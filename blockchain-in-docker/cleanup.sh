#!/bin/bash

command -v 'docker-compose' > /dev/null 2>&1 || { echo >&2 "docker-compose is required"; exit 1; }

down() {
    CHAIN_NO=$1
    DCF="network$CHAIN_NO.yml"

    if [ -f "$DCF" ]; then
        echo "Shutting down chain $CHAIN_NO"
        docker-compose -f "$DCF" down
    else
        echo "Can not shutdown containers of chain $CHAIN_NO because docker compose file $DCF could not be found"
    fi
}

down 1
down 2