#!/bin/bash

command -v 'docker-compose' > /dev/null 2>&1 || { echo >&2 "docker-compose is required"; exit 1; }

echo 'docker-compose down'
docker-compose -f network1.yml down
docker-compose -f network2.yml down