#!/bin/bash

source ../env.sh

echo
read -p "Are you sure want to stop and destroy all resources relate to this example? (Y/n)" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo 'Stopping services'
    sudo systemctl stop $EVMOS_BINARY'10' $EVMOS_BINARY'11' $EVMOS_BINARY'12' $EVMOS_BINARY'20' $EVMOS_BINARY'21' $EVMOS_BINARY'22'
    sleep 2s
    echo 'Disable services'
    sudo systemctl disable $EVMOS_BINARY'10'
    sudo systemctl disable $EVMOS_BINARY'11'
    sudo systemctl disable $EVMOS_BINARY'12'
    sudo systemctl disable $EVMOS_BINARY'20'
    sudo systemctl disable $EVMOS_BINARY'21'
    sudo systemctl disable $EVMOS_BINARY'22'
    echo 'Remove service files'
    sudo rm -f '/etc/systemd/system/'$EVMOS_BINARY'10.service'
    sudo rm -f '/etc/systemd/system/'$EVMOS_BINARY'11.service'
    sudo rm -f '/etc/systemd/system/'$EVMOS_BINARY'12.service'
    sudo rm -f '/etc/systemd/system/'$EVMOS_BINARY'20.service'
    sudo rm -f '/etc/systemd/system/'$EVMOS_BINARY'21.service'
    sudo rm -f '/etc/systemd/system/'$EVMOS_BINARY'22.service'
    echo "Removing home $HOME/.$EVMOS_BINARY*"
    sudo rm -rf $HOME'/.'$EVMOS_BINARY'10'
    sudo rm -rf $HOME'/.'$EVMOS_BINARY'11'
    sudo rm -rf $HOME'/.'$EVMOS_BINARY'12'
    sudo rm -rf $HOME'/.'$EVMOS_BINARY'20'
    sudo rm -rf $HOME'/.'$EVMOS_BINARY'21'
    sudo rm -rf $HOME'/.'$EVMOS_BINARY'22'
    echo 'Done'
fi