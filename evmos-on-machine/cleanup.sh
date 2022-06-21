#!/bin/bash

source ../env.sh

echo
read -p "Are you sure want to stop and destroy all resources relate to this example? (Y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo 'Stopping services'
    sudo systemctl stop evmosd10 evmosd11 evmosd12 evmosd20 evmosd21 evmosd22
    sleep 2s
    echo 'Disable services'
    sudo systemctl disable evmosd10
    sudo systemctl disable evmosd11
    sudo systemctl disable evmosd12
    sudo systemctl disable evmosd20
    sudo systemctl disable evmosd21
    sudo systemctl disable evmosd22
    echo 'Remove service files'
    sudo rm -f /etc/systemd/system/evmosd10.service
    sudo rm -f /etc/systemd/system/evmosd11.service
    sudo rm -f /etc/systemd/system/evmosd12.service
    sudo rm -f /etc/systemd/system/evmosd20.service
    sudo rm -f /etc/systemd/system/evmosd21.service
    sudo rm -f /etc/systemd/system/evmosd22.service
    echo 'Removing home ~/.evmosd*'
    sudo rm -rf ~/.evmosd10
    sudo rm -rf ~/.evmosd11
    sudo rm -rf ~/.evmosd12
    sudo rm -rf ~/.evmosd20
    sudo rm -rf ~/.evmosd21
    sudo rm -rf ~/.evmosd22
    echo 'Done'
fi