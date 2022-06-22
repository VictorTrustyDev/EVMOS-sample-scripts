#!/bin/bash

echo 'docker-compose down'
docker-compose -f network1.yml down
docker-compose -f network2.yml down

rm -rf .evmosd*/
rm -rf EVMOS-source-code-*/