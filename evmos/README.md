### Contains sample scripts which guide you how to create a simple EVMOS network

#### This sample will create a simple EVMOS network with 3 validators pre-defined

##### Step 1: grant executable permission for scripts
$ chmod +x *.sh

##### Step 2: create network
$ ./create-network-on-machine.sh 1

##### Step 3: create validator
$ ./create-validator.sh 2
$ ./create-validator.sh 3

Want more validator? Just create more, no problem