#!/bin/bash

source ../env.sh

docker-compose down -f network1.yml

docker-compose up -f network1.yml -d