#!/bin/bash

source ./env.sh

if [ -f "./override-env.sh" ]; then
    source "./override-env.sh"
fi

$BDJUNO_BINARY parse genesis-file --genesis-file-path $BDJUNO_HOME/genesis.json

echo 'Setup daemon process'
sudo tee /etc/systemd/system/bdjuno.service > /dev/null <<EOF
[Unit]
Description=BDJuno parser
After=network-online.target

[Service]
User=$USER
ExecStart=$BDJUNO_BINARY start
Restart=always
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable bdjuno
sudo systemctl start bdjuno

echo 'Finished bdjuno installtion'

echo 'Now move to install Hasura by running install-3.sh'


